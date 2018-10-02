import random
import re
import subprocess
import os
import filecmp

window_i_file = '../window.txt'
axis_i_file = '../axis_i.txt'
axis_o_file = '../axis_o.txt'
axis_check_file = '../axis_o_check.txt'
math_log_file = '../check.log'


def rand_complex32():
    """Returns randomized complex value with Re and Im in short type range"""
    im = random.randrange(-32768, 32767)
    re = random.randrange(-32768, 32767)
    return complex(re, im)


def int_to_short(a, bits=16):
    return int(a) & (2 ** bits - 1)


def gen_input(size, pack_num=1, bus_num=2, file=axis_i_file):
    """Creates and returns list of lists with input axis transactions and generates input file"""
    trans_num = int(size / bus_num)
    packet_list = []
    with open(file, "w+") as f:
        for p in range(pack_num):
            # generate packet
            packet = []
            for i in range(trans_num):
                # generate data
                for b in range(bus_num):
                    data = rand_complex32()
                    packet.append(data)
                    f.write("{0:04x}{1:04x}_".format(int_to_short(data.imag), int_to_short(data.real)))
                f.write("\n")

            # add packet to list
            packet_list.append(packet)

    return packet_list


def gen_window(size, file=window_i_file):
    """Creates and returns list of window samples and generates input window file"""
    window = []
    with open(file, "w+") as f:
        for i in range(size):
            data = rand_complex32()
            window.append(data)
            f.write("{0:04x}{1:04x}\n".format(int_to_short(data.imag), int_to_short(data.real)))

    return window


def gen_reference(out_data_list, bus_num=2, file=axis_check_file):
    """Creates file with output reference transactions"""
    with open(file, "w+") as f:
        for l in out_data_list:
            l_tmp = l.copy()
            while len(l_tmp) > bus_num:
                f.write("0_")
                for b in range(bus_num):
                    trans_part = l_tmp.pop(0)
                    f.write("{0:08x}{1:08x}".format(int_to_short(trans_part.imag, 32), int_to_short(trans_part.real, 32)))
                f.write("\n")
            else:
                f.write("1_")
                for b in range(bus_num):
                    trans_part = l_tmp.pop(0)
                    f.write("{0:08x}{1:08x}".format(int_to_short(trans_part.imag, 32), int_to_short(trans_part.real, 32)))
                f.write("\n")


def run_test(packet_size=64, packet_num=5, bus_num=2, revert_addr=False, rand_input=False, rand_output=False):
    print('Run configuration: FFT_SIZE={:d}, BUS_NUM={:d}, APB_A_REV={:d}, IN_RAND={:d}, OUT_RAND={:d} -- '.format(
        packet_size, bus_num, revert_addr, rand_input, rand_output),
        end='')

    # generate input transactions
    inp = gen_input(packet_size, packet_num, bus_num)
    win_tmp = gen_window(packet_size)
    win = win_tmp.copy()

    # revert address bits if necessary
    if revert_addr:
        for i in range(packet_size):
            i_rev = int('{0:0{1}b}'.format(i, packet_size.bit_length() - 1)[::-1], 2)
            win[i] = win_tmp[i_rev]

    # generate reference result
    math_log = open(math_log_file, 'w')
    math_log.write('data * window = result\n')
    result = []
    for p in inp:
        rp = []
        for i in range(len(p)):
            rp.append(p[i] * win[i])
            math_log.write(str(p[i]) + ' * ' + str(win[i]) + ' = ' + str(p[i] * win[i]) + '\n')
        result.append(rp)

    gen_reference(result, bus_num)

    # run vsim
    script_conf = '-do "do run.tcl'
    script_conf += ' {}'.format(packet_size)
    script_conf += ' {}'.format(bus_num)
    script_conf += ' 1' if revert_addr else ' 0'
    script_conf += ' 1' if rand_input else ' 0'
    script_conf += ' 1' if rand_output else ' 0'
    script_conf += '"'

    vsim = 'vsim -c ' + script_conf

    subprocess.call(vsim, shell=True, stdout=subprocess.DEVNULL)

    # check results
    if filecmp.cmp(axis_o_file, axis_check_file):
        print('Check passed!')
        math_log.write('Check passed!')
    else:
        print('Files do not match!', end=' ')
        math_log.write('Files do not match!')
        print('({})'.format(vsim))
    math_log.close()


if __name__ == '__main__':

    packet_size_cases = [128, 512, 2048, 4096, 8192]
    bus_num_cases = [2, 4, 8]
    revert_addr_cases = [True, False]
    rand_input_cases = [True, False]
    rand_output_cases = [True, False]

    for rev in revert_addr_cases:
        for b in bus_num_cases:
            for size in packet_size_cases:
                for i in rand_input_cases:
                    for o in rand_output_cases:
                        run_test(packet_size=size, packet_num=10, bus_num=b, revert_addr=rev, rand_input=i, rand_output=o)

    # run_test(packet_size=32,packet_num=5,bus_num=4,revert_addr=False,rand_input=True,rand_output=True)
