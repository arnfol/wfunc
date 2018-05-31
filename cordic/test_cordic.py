import math

def cordic(angleN,K,N):
    fin_angleN = fin_angleR = 0
    xr = x = math.pow(2,(K))
    yr = y = 0
    norm = math.pow(2,(K))
    # 1/( math.atan(math.pow(2,-(K))) )
    # math.pow(2,(K))
    # ( math.atan(math.pow(2,-(K))) )
    print((angleN/N)*norm)
    angleR = angleN/N*180
    for i in range(K):
        PI = math.acos(-1)
        i_angleN    = math.floor((math.atan(math.pow(2,-i)))/PI*norm)
        i_angleR    = (math.atan(math.pow(2,-i)))/PI*180
        # real_angle = i_angle/(N*2**(K-3))*180
        # print("N :[%d] atan = %f " % (i,i_angleN))
        # print("R :[%d] atan = %f " % (i,i_angleR))
        print("turn = %d" % (fin_angleN < angleN*norm/N))
        print("turn2 = %d" % (fin_angleR < angleR))
        print("angleN = %d, fin_angleN = %d" % (angleN*norm/N,fin_angleN))
        print("angleR = %d, fin_angleR = %d" % (angleR,fin_angleR))
        if((fin_angleN) < (angleN/N)*norm):
            fin_angleN += i_angleN
        else :
            fin_angleN -= i_angleN

        if(fin_angleR < angleR):
            fin_angleR += i_angleR
            tmp = xr;
            xr -= yr*( math.pow(2,-i) )
            yr += tmp*( math.pow(2,-i) )
        # elif(fin_angleR > angleR):
        else:
            tmp = xr;
            xr += yr*( math.pow(2,-i) )
            yr -= tmp*( math.pow(2,-i) )
            fin_angleR -= i_angleR
        print("xr = %f, yr = %f" % (xr,yr))
        # print("xr = %f, yr = %f" % (xr,yr))
        # print("xr = %f, yr = %f" % (xr*0.607,yr*0.607))
    print("fin angleN = %f" % (fin_angleN))
    print("fin angleN = %f" % (fin_angleN/norm*180))
    print("fin angleR = %f" % fin_angleR)
    return fin_angleR

# for st_num in range(4,18):
#     prev_diff = 2
#     for cr_st in range(1,st_num+7):
#         diff = 0
#         for ang in range(2**(st_num-1)):
#             result = cordic(ang,cr_st,2**st_num)
#             diff += abs(ang/(2**st_num)*180 - result)
#             # print("\tneeded angle = %f, result = %f" % (ang/(2**st_num)*180,result))
#         if(prev_diff > 1 and diff < 1) :
#             print("NFFT = %d" % 2**st_num)
#             print("\tstage = %d" % st_num)
#             print("\tcr_st = %d" % cr_st)
#             print("\tdiff = %f" % diff)
#         prev_diff = diff
diff = 0
for ang in range(128):
            result = cordic(ang,12,256)
            diff += abs(ang/(256)*180 - result)
            print("\tneeded angle = %f, result = %f" % (ang/(256)*180,result))
