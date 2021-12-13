const String avatarUrl =
    'https://keylol.com/uc_server/avatar.php?size=small&uid=';

const String avatarUrlLarge =
    'https://keylol.com/uc_server/avatar.php?size=large&uid=';

const EMOJI_MAP = {
  '茸茸1': [
    {
      'https://keylol.com/static/image/smiley/kylo_1/r2emo_08_googoo.png':
      '{:kylo1_24:}'
    },
    {
      'https://keylol.com/static/image/smiley/kylo_1/r2emo_05_kitten.png':
      '{:kylo1_26:}'
    },
    {
      'https://keylol.com/static/image/smiley/kylo_1/r2emo_13_backstab.png':
      '{:kylo1_25:}'
    },
    {
      'https://keylol.com/static/image/smiley/kylo_1/r2emo_15_yummy.png':
      '{:kylo1_27:}'
    },
    {
      'https://keylol.com/static/image/smiley/kylo_1/r2emo_03_dalao.png':
      '{:kylo1_21:}'
    },
    {
      'https://keylol.com/static/image/smiley/kylo_1/r2emo_01_gkd.png':
      '{:kylo1_28:}'
    },
    {
      'https://keylol.com/static/image/smiley/kylo_1/r2emo_09_love.png':
      '{:kylo1_16:}'
    },
    {
      'https://keylol.com/static/image/smiley/kylo_1/r2emo_12_plus.png':
      '{:kylo1_12:}'
    },
    {
      'https://keylol.com/static/image/smiley/kylo_1/r2emo_11_minus.png':
      '{:kylo1_17:}'
    },
    {
      'https://keylol.com/static/image/smiley/kylo_1/r2emo_11_minus.png':
      '{:kylo1_18:}'
    },
    {
      'https://keylol.com/static/image/smiley/kylo_1/r2emo_06_grass.png':
      '{:kylo1_19:}'
    },
    {
      'https://keylol.com/static/image/smiley/kylo_1/r2emo_04b_lemon-sour.png':
      '{:kylo1_20:}'
    },
    {
      'https://keylol.com/static/image/smiley/kylo_1/r2emo_04a_lemon-sad.png':
      '{:kylo1_11:}'
    },
    {
      'https://keylol.com/static/image/smiley/kylo_1/r2emo_16_ahhh.png':
      '{:kylo1_13:}'
    },
    {
      'https://keylol.com/static/image/smiley/kylo_1/r2emo_02_kp.png':
      '{:kylo1_14:}'
    },
    {
      'https://keylol.com/static/image/smiley/kylo_1/r2emo_10_liver-killer.png':
      '{:kylo1_15:}'
    }
  ],
  '茸茸2': [
    {'https://keylol.com/static/image/smiley/kylo_2/17.gif': '{:kylo2_18:}'},
    {'https://keylol.com/static/image/smiley/kylo_2/16.gif': '{:kylo2_27:}'},
    {'https://keylol.com/static/image/smiley/kylo_2/03.gif': '{:kylo2_26:}'},
    {'https://keylol.com/static/image/smiley/kylo_2/14.gif': '{:kylo2_21:}'},
    {'https://keylol.com/static/image/smiley/kylo_2/18.gif': '{:kylo2_22:}'},
    {'https://keylol.com/static/image/smiley/kylo_2/07.gif': '{:kylo2_13:}'},
    {'https://keylol.com/static/image/smiley/kylo_2/04.gif': '{:kylo2_15:}'},
    {'https://keylol.com/static/image/smiley/kylo_2/01.gif': '{:kylo2_16:}'},
    {'https://keylol.com/static/image/smiley/kylo_2/09.gif': '{:kylo2_20:}'},
    {'https://keylol.com/static/image/smiley/kylo_2/06.gif': '{:kylo2_11:}'},
    {'https://keylol.com/static/image/smiley/kylo_2/10.gif': '{:kylo2_17:}'},
    {'https://keylol.com/static/image/smiley/kylo_2/08.gif': '{:kylo2_19:}'},
    {'https://keylol.com/static/image/smiley/kylo_2/11.gif': '{:kylo2_12:}'},
    {'https://keylol.com/static/image/smiley/kylo_2/05.gif': '{:kylo2_23:}'},
    {'https://keylol.com/static/image/smiley/kylo_2/02.gif': '{:kylo2_25:}'},
    {'https://keylol.com/static/image/smiley/kylo_2/13.gif': '{:kylo2_14:}'},
    {'https://keylol.com/static/image/smiley/kylo_2/12.gif': '{:kylo2_24:}'}
  ],
  'G胖': [
    {'https://keylol.com/static/image/smiley/gaben/1.gif': '{:不不不:}'},
    {'https://keylol.com/static/image/smiley/gaben/12.gif': '{:特卖:}'},
    {'https://keylol.com/static/image/smiley/gaben/2.gif': '{:临时工:}'},
    {'https://keylol.com/static/image/smiley/gaben/5.gif': '{:吃土:}'},
    {'https://keylol.com/static/image/smiley/gaben/6.gif': '{:吃惊:}'},
    {'https://keylol.com/static/image/smiley/gaben/7.gif': '{:唔:}'},
    {'https://keylol.com/static/image/smiley/gaben/19.gif': '{:+1:}'},
    {'https://keylol.com/static/image/smiley/gaben/8.gif': '{:喜+1:}'},
    {'https://keylol.com/static/image/smiley/gaben/11.gif': '{:抓狂:}'},
    {'https://keylol.com/static/image/smiley/gaben/13.gif': '{:礼物:}'},
    {'https://keylol.com/static/image/smiley/gaben/10.gif': '{:打折:}'},
    {'https://keylol.com/static/image/smiley/gaben/3.gif': '{:为自己购买:}'},
    {'https://keylol.com/static/image/smiley/gaben/9.gif': '{:大哭:}'},
    {'https://keylol.com/static/image/smiley/gaben/16.gif': '{:老哥稳:}'},
    {'https://keylol.com/static/image/smiley/gaben/14.gif': '{:立刻购买:}'},
    {'https://keylol.com/static/image/smiley/gaben/20.gif': '{:-1:}'},
    {'https://keylol.com/static/image/smiley/gaben/18.gif': '{:闭嘴:}'},
    {'https://keylol.com/static/image/smiley/gaben/15.gif': '{:绿一片:}'},
    {'https://keylol.com/static/image/smiley/gaben/4.gif': '{:可爱:}'},
    {'https://keylol.com/static/image/smiley/gaben/17.gif': '{:考虑:}'},
    {'https://keylol.com/static/image/smiley/gaben/21.gif': '{:soon:}'}
  ],
  '阿鲁1': [
    {
      'https://keylol.com/static/image/smiley/steamcn_9/0140.gif': '{:17_1001:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_9/0180.gif': '{:17_1008:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_9/0181.gif': '{:17_1005:}'
    },
    {'https://keylol.com/static/image/smiley/steamcn_9/0080.gif': '{:17_998:}'},
    {
      'https://keylol.com/static/image/smiley/steamcn_9/0450.gif': '{:17_1010:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_9/0390.gif': '{:17_1013:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_9/0350.gif': '{:17_1051:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_9/0460.gif': '{:17_1048:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_9/0160.gif': '{:17_1036:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_9/0340.gif': '{:17_1035:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_9/0130.gif': '{:17_1037:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_9/0020.gif': '{:17_1041:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_9/0510.gif': '{:17_1044:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_9/0580.gif': '{:17_1040:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_9/0200.gif': '{:17_1045:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_9/0000.gif': '{:17_1047:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_9/0560.gif': '{:17_1016:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_9/0170.gif': '{:17_1029:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_9/3040.gif': '{:17_1027:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_9/0330.gif': '{:17_1026:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_9/0590.gif': '{:17_1022:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_9/0461.gif': '{:17_1021:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_9/0540.gif': '{:17_1020:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_9/0040.gif': '{:17_1019:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_9/3011.gif': '{:17_1018:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_9/0480.gif': '{:17_1032:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_9/3010.gif': '{:17_1015:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_9/0620.gif': '{:17_1000:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_9/0260.gif': '{:17_1052:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_9/0120.gif': '{:17_1028:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_9/0190.gif': '{:17_1023:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_9/0100.gif': '{:17_1024:}'
    },
    {'https://keylol.com/static/image/smiley/steamcn_9/0050.gif': '{:17_999:}'},
    {
      'https://keylol.com/static/image/smiley/steamcn_9/0150.gif': '{:17_1004:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_9/0220.gif': '{:17_1007:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_9/0010.gif': '{:17_1009:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_9/0230.gif': '{:17_1011:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_9/0240.gif': '{:17_1053:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_9/0250.gif': '{:17_1056:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_9/0210.gif': '{:17_1057:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_9/0360.gif': '{:17_1049:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_9/0300.gif': '{:17_1034:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_9/0391.gif': '{:17_1042:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_9/0400.gif': '{:17_1043:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_9/0420.gif': '{:17_1033:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_9/0290.gif': '{:17_1002:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_9/2101.gif': '{:17_1055:}'
    },
    {'https://keylol.com/static/image/smiley/steamcn_9/3060.gif': '{:17_996:}'},
    {
      'https://keylol.com/static/image/smiley/steamcn_9/0500.gif': '{:17_1054:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_9/3061.gif': '{:17_1046:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_9/0550.gif': '{:17_1039:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_9/3030.gif': '{:17_1030:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_9/2100.gif': '{:17_1025:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_9/0530.gif': '{:17_1017:}'
    },
    {'https://keylol.com/static/image/smiley/steamcn_9/0520.gif': '{:17_997:}'},
    {
      'https://keylol.com/static/image/smiley/steamcn_9/0490.gif': '{:17_1058:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_9/1011.gif': '{:17_1012:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_9/1010.gif': '{:17_1038:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_9/2170.gif': '{:17_1006:}'
    },
    {'https://keylol.com/static/image/smiley/steamcn_9/4021.gif': '{:17_995:}'},
    {
      'https://keylol.com/static/image/smiley/steamcn_9/4112.gif': '{:17_1050:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_9/4010.gif': '{:17_1031:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_9/4100.gif': '{:17_1003:}'
    },
    {'https://keylol.com/static/image/smiley/steamcn_9/4041.gif': '{:17_1014:}'}
  ],
  '阿鲁2': [
    {
      'https://keylol.com/static/image/smiley/steamcn_10/5220.gif': '{:15_934:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_10/6121.gif': '{:15_932:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_10/5010.gif': '{:15_930:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_10/6001.gif': '{:15_928:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_10/8000.gif': '{:15_926:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_10/x013.gif': '{:15_924:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_10/6061.gif': '{:15_922:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_10/5020.gif': '{:15:920:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_10/5130.gif': '{:15_918:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_10/x061.gif': '{:15_916:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_10/5030.gif': '{:15_914:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_10/5161.gif': '{:15_945:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_10/6051.gif': '{:15_941:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_10/7113.gif': '{:15_939:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_10/5001.gif': '{:15_937:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_10/6050.gif': '{:15_935:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_10/6040.gif': '{:15_933:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_10/5190.gif': '{:15_931:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_10/5180.gif': '{:15_929:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_10/6060.gif': '{:15_927:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_10/5150.gif': '{:15_925:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_10/5230.gif': '{:15_923:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_10/5070.gif': '{:15_921:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_10/5000.gif': '{:15_919:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_10/5131.gif': '{:15_917:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_10/5050.gif': '{:15_913:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_10/5140.gif': '{:15_944:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_10/5210.gif': '{:15_946:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_10/5170.gif': '{:15_942:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_10/8070.gif': '{:15_943:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_10/5120.gif': '{:15_948:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_10/5080.gif': '{:15_940:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_10/5090.gif': '{:15_938:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_10/5091.gif': '{:15_936:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_10/5151.gif': '{:15_949:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_10/5100.gif': '{:15_947:}'
    },
    {'https://keylol.com/static/image/smiley/steamcn_10/5141.gif': '{:15_915:}'}
  ],
  '阿鲁3': [
    {
      'https://keylol.com/static/image/smiley/steamcn_11/7040.gif': '{:18_961:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_11/6030.gif': '{:18_992:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_11/6020.gif': '{:18_978:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_11/6010.gif': '{:18_988:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_11/8010.gif': '{:18_993:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_11/8001.gif': '{:18_955:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_11/8020.gif': '{:18_991:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_11/6100.gif': '{:18_959:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_11/6090.gif': '{:18_967:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_11/7051.gif': '{:18_951:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_11/7201.gif': '{:18_982:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_11/7200.gif': '{:18_974:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_11/7210.gif': '{:18_972:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_11/7090.gif': '{:18_968:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_11/7100.gif': '{:18_963:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_11/6070.gif': '{:18_973:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_11/7071.gif': '{:18_980:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_11/7062.gif': '{:18_990:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_11/7081.gif': '{:18_984:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_11/7053.gif': '{:18_950:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_11/7080.gif': '{:18_954:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_11/6500.gif': '{:18_965:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_11/6520.gif': '{:18_994:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_11/6530.gif': '{:18_986:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_11/6140.gif': '{:18_971:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_11/6091.gif': '{:18_989:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_11/6150.gif': '{:18_958:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_11/7230.gif': '{:18_981:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_11/8081.gif': '{:18_975:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_11/8082.gif': '{:18_957:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_11/8083.gif': '{:18_960:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_11/8084.gif': '{:18_952:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_11/7220.gif': '{:18_977:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_11/x083.gif': '{:18_985:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_11/x082.gif': '{:18_970:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_11/x080.gif': '{:18_956:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_11/x021.gif': '{:18_953:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_11/x031.gif': '{:18_962:}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_11/x041.gif': '{:18_966:}'
    },
    {'https://keylol.com/static/image/smiley/steamcn_11/x032.gif': '{:18_979:}'}
  ],
  '嗷大喵1': [
    {'https://keylol.com/static/image/smiley/steamcn_5/kbc116.gif': ':+:{挖鼻孔}'},
    {'https://keylol.com/static/image/smiley/steamcn_5/kbc118.gif': ':+:{无语}'},
    {'https://keylol.com/static/image/smiley/steamcn_5/kbc121.gif': ':+:{疑惑}'},
    {'https://keylol.com/static/image/smiley/steamcn_5/kbc114.gif': ':+:{怒}'},
    {'https://keylol.com/static/image/smiley/steamcn_5/kbc124.gif': ':+:{震惊哭}'},
    {'https://keylol.com/static/image/smiley/steamcn_5/kbc113.gif': ':+:{奸笑}'},
    {
      'https://keylol.com/static/image/smiley/steamcn_5/kbc120.gif': ':+:{内牛满面}'
    },
    {'https://keylol.com/static/image/smiley/steamcn_5/kbc109.gif': ':+:{你懂的}'},
    {'https://keylol.com/static/image/smiley/steamcn_5/kbc123.gif': ':+:{赞}'},
    {'https://keylol.com/static/image/smiley/steamcn_5/kbc112.gif': ':+:{吐血}'},
    {'https://keylol.com/static/image/smiley/steamcn_5/kbc119.gif': ':+:{晃脑}'},
    {'https://keylol.com/static/image/smiley/steamcn_5/kbc115.gif': ':+:{思考}'},
    {'https://keylol.com/static/image/smiley/steamcn_5/kbc125.gif': ':+:{靠墙哭}'},
    {'https://keylol.com/static/image/smiley/steamcn_5/kbc111.gif': ':+:{可爱撒}'},
    {'https://keylol.com/static/image/smiley/steamcn_5/kbc122.gif': ':+:{羞羞}'},
    {'https://keylol.com/static/image/smiley/steamcn_5/kbc127.gif': ':+:{鼓掌}'},
    {'https://keylol.com/static/image/smiley/steamcn_5/kbc126.gif': ':+:{高兴}'},
    {'https://keylol.com/static/image/smiley/steamcn_5/kbc117.gif': ':+:{无聊}'},
    {'https://keylol.com/static/image/smiley/steamcn_5/kbc110.gif': ':+:{卖萌}'},
    {'https://keylol.com/static/image/smiley/steamcn_5/kbc108.gif': ':+:{你好呀}'}
  ],
  '嗷大喵2': [
    {'https://keylol.com/static/image/smiley/steamcn_7/kbc143.gif': ':+:{么么哒}'},
    {'https://keylol.com/static/image/smiley/steamcn_7/kbc144.gif': ':+:{冷笑}'},
    {'https://keylol.com/static/image/smiley/steamcn_7/kbc145.gif': ':+:{发火}'},
    {'https://keylol.com/static/image/smiley/steamcn_7/kbc146.gif': ':+:{坏笑}'},
    {'https://keylol.com/static/image/smiley/steamcn_7/kbc147.gif': ':+:{大笑}'},
    {'https://keylol.com/static/image/smiley/steamcn_7/kbc148.gif': ':+:{奋斗}'},
    {'https://keylol.com/static/image/smiley/steamcn_7/kbc149.gif': ':+:{好的}'},
    {'https://keylol.com/static/image/smiley/steamcn_7/kbc150.gif': ':+:{委屈}'},
    {'https://keylol.com/static/image/smiley/steamcn_7/kbc151.gif': ':+:{安慰}'},
    {'https://keylol.com/static/image/smiley/steamcn_7/kbc152.gif': ':+:{真帅}'},
    {'https://keylol.com/static/image/smiley/steamcn_7/kbc153.gif': ':+:{幸福}'},
    {'https://keylol.com/static/image/smiley/steamcn_7/kbc154.gif': ':+:{心塞}'},
    {'https://keylol.com/static/image/smiley/steamcn_7/kbc155.gif': ':+:{打脸}'},
    {'https://keylol.com/static/image/smiley/steamcn_7/kbc156.gif': ':+:{拜拜}'},
    {'https://keylol.com/static/image/smiley/steamcn_7/kbc157.gif': ':+:{捏捏}'},
    {'https://keylol.com/static/image/smiley/steamcn_7/kbc158.gif': ':+:{放电}'},
    {'https://keylol.com/static/image/smiley/steamcn_7/kbc159.gif': ':+:{汗}'},
    {'https://keylol.com/static/image/smiley/steamcn_7/kbc160.gif': ':+:{泪奔}'},
    {'https://keylol.com/static/image/smiley/steamcn_7/kbc161.gif': ':+:{流口水}'},
    {'https://keylol.com/static/image/smiley/steamcn_7/kbc162.gif': ':+:{激动}'},
    {'https://keylol.com/static/image/smiley/steamcn_7/kbc163.gif': ':+:{电臀}'},
    {'https://keylol.com/static/image/smiley/steamcn_7/kbc164.gif': ':+:{讨厌}'},
    {
      'https://keylol.com/static/image/smiley/steamcn_7/kbc165.gif': ':+:{该吃药了}'
    },
    {'https://keylol.com/static/image/smiley/steamcn_7/kbc166.gif': ':+:{运动}'},
    {'https://keylol.com/static/image/smiley/steamcn_7/kbc167.gif': ':+:{道歉}'},
    {'https://keylol.com/static/image/smiley/steamcn_7/kbc168.gif': ':+:{震惊}'},
    {'https://keylol.com/static/image/smiley/steamcn_7/kbc169.gif': ':+:{顶球}'},
    {'https://keylol.com/static/image/smiley/steamcn_7/kbc170.gif': ':+:{飘动}'}
  ],
  '嗷大喵3': [
    {'https://keylol.com/static/image/smiley/steamcn_8/kbc171.gif': ':+:{买买买}'},
    {
      'https://keylol.com/static/image/smiley/steamcn_8/kbc173.gif': ':+:{买买买买}'
    },
    {
      'https://keylol.com/static/image/smiley/steamcn_8/kbc187.gif':
      ':+:{买买买gog}'
    },
    {'https://keylol.com/static/image/smiley/steamcn_8/kbc172.gif': ':+:{闪卡}'},
    {'https://keylol.com/static/image/smiley/steamcn_8/kbc174.gif': ':+:{买买}'},
    {'https://keylol.com/static/image/smiley/steamcn_8/kbc175.gif': ':+:{好人卡}'},
    {
      'https://keylol.com/static/image/smiley/steamcn_8/kbc176.gif':
      ':+:{再买就剁手}'
    },
    {'https://keylol.com/static/image/smiley/steamcn_8/kbc177.gif': ':+:{随便花}'},
    {'https://keylol.com/static/image/smiley/steamcn_8/kbc178.gif': ':+:{单身狗}'},
    {
      'https://keylol.com/static/image/smiley/steamcn_8/kbc179.gif': ':+:{脱团可耻}'
    },
    {'https://keylol.com/static/image/smiley/steamcn_8/kbc180.gif': ':+:{一个人}'},
    {'https://keylol.com/static/image/smiley/steamcn_8/kbc181.gif': ':+:{秀恩爱}'},
    {'https://keylol.com/static/image/smiley/steamcn_8/kbc182.gif': ':+:{寂寞了}'},
    {'https://keylol.com/static/image/smiley/steamcn_8/kbc183.gif': ':+:{无所谓}'},
    {'https://keylol.com/static/image/smiley/steamcn_8/kbc184.gif': ':+:{约吗}'},
    {'https://keylol.com/static/image/smiley/steamcn_8/kbc185.gif': ':+:{心空}'},
    {'https://keylol.com/static/image/smiley/steamcn_8/kbc186.gif': ':+:{闷酒}'}
  ],
  '洋葱头': [
    {'https://keylol.com/static/image/smiley/steamcn_1/kbc55.gif': ':+:55'},
    {'https://keylol.com/static/image/smiley/steamcn_1/kbc09.gif': ':+:09'},
    {'https://keylol.com/static/image/smiley/steamcn_1/kbc02.gif': ':+:02'},
    {'https://keylol.com/static/image/smiley/steamcn_1/kbc03.gif': ':+:03'},
    {'https://keylol.com/static/image/smiley/steamcn_1/kbc16.gif': ':+:16'},
    {'https://keylol.com/static/image/smiley/steamcn_1/kbc22.gif': ':+:22'},
    {'https://keylol.com/static/image/smiley/steamcn_1/kbc31.gif': ':+:31'},
    {'https://keylol.com/static/image/smiley/steamcn_1/kbc34.gif': ':+:34'},
    {'https://keylol.com/static/image/smiley/steamcn_1/kbc53.gif': ':+:53'},
    {'https://keylol.com/static/image/smiley/steamcn_1/kbc07.gif': ':+:07'},
    {'https://keylol.com/static/image/smiley/steamcn_1/kbc52.gif': ':+:52'},
    {'https://keylol.com/static/image/smiley/steamcn_1/kbc56.gif': ':+:56'},
    {'https://keylol.com/static/image/smiley/steamcn_1/kbc15.gif': ':+:15'},
    {'https://keylol.com/static/image/smiley/steamcn_1/kbc58.gif': ':+:58'},
    {'https://keylol.com/static/image/smiley/steamcn_1/kbc01.gif': ':+:01'},
    {'https://keylol.com/static/image/smiley/steamcn_1/kbc13.gif': ':+:13'},
    {'https://keylol.com/static/image/smiley/steamcn_1/kbc73.gif': ':+:73'},
    {'https://keylol.com/static/image/smiley/steamcn_1/kbc79.gif': ':+:79'},
    {'https://keylol.com/static/image/smiley/steamcn_1/kbc71.gif': ':+:71'},
    {'https://keylol.com/static/image/smiley/steamcn_1/kbc80.gif': ':+:80'},
    {'https://keylol.com/static/image/smiley/steamcn_1/kbc72.gif': ':+:72'},
    {'https://keylol.com/static/image/smiley/steamcn_1/kbc81.gif': ':+:81'},
    {'https://keylol.com/static/image/smiley/steamcn_1/kbc82.gif': ':+:82'},
    {'https://keylol.com/static/image/smiley/steamcn_1/kbc04.gif': ':+:04'},
    {'https://keylol.com/static/image/smiley/steamcn_1/kbc05.gif': ':+:05'},
    {'https://keylol.com/static/image/smiley/steamcn_1/kbc06.gif': ':+:06'},
    {'https://keylol.com/static/image/smiley/steamcn_1/kbc74.gif': ':+:74'},
    {'https://keylol.com/static/image/smiley/steamcn_1/kbc08.gif': ':+:08'},
    {'https://keylol.com/static/image/smiley/steamcn_1/kbc77.gif': ':+:77'},
    {'https://keylol.com/static/image/smiley/steamcn_1/kbc10.gif': ':+:10'},
    {'https://keylol.com/static/image/smiley/steamcn_1/kbc11.gif': ':+:11'},
    {'https://keylol.com/static/image/smiley/steamcn_1/kbc12.gif': ':+:12'},
    {'https://keylol.com/static/image/smiley/steamcn_1/kbc76.gif': ':+:76'},
    {'https://keylol.com/static/image/smiley/steamcn_1/kbc14.gif': ':+:14'},
    {'https://keylol.com/static/image/smiley/steamcn_1/kbc75.gif': ':+:75'},
    {'https://keylol.com/static/image/smiley/steamcn_1/kbc78.gif': ':+:78'},
    {'https://keylol.com/static/image/smiley/steamcn_1/kbc17.gif': ':+:17'},
    {'https://keylol.com/static/image/smiley/steamcn_1/kbc18.gif': ':+:18'},
    {'https://keylol.com/static/image/smiley/steamcn_1/kbc19.gif': ':+:19'},
    {'https://keylol.com/static/image/smiley/steamcn_1/kbc20.gif': ':+:20'},
    {'https://keylol.com/static/image/smiley/steamcn_1/kbc21.gif': ':+:21'},
    {'https://keylol.com/static/image/smiley/steamcn_1/kbc88.gif': ':+:88'},
    {'https://keylol.com/static/image/smiley/steamcn_1/kbc23.gif': ':+:23'},
    {'https://keylol.com/static/image/smiley/steamcn_1/kbc83.gif': ':+:83'},
    {'https://keylol.com/static/image/smiley/steamcn_1/kbc25.gif': ':+:25'},
    {'https://keylol.com/static/image/smiley/steamcn_1/kbc26.gif': ':+:26'},
    {'https://keylol.com/static/image/smiley/steamcn_1/kbc27.gif': ':+:27'},
    {'https://keylol.com/static/image/smiley/steamcn_1/kbc28.gif': ':+:28'},
    {'https://keylol.com/static/image/smiley/steamcn_1/kbc29.gif': ':+:29'},
    {'https://keylol.com/static/image/smiley/steamcn_1/kbc30.gif': ':+:30'},
    {'https://keylol.com/static/image/smiley/steamcn_1/kbc84.gif': ':+:84'},
    {'https://keylol.com/static/image/smiley/steamcn_1/kbc32.gif': ':+:32'},
    {'https://keylol.com/static/image/smiley/steamcn_1/kbc33.gif': ':+:33'},
    {'https://keylol.com/static/image/smiley/steamcn_1/kbc24.gif': ':+:24'},
    {'https://keylol.com/static/image/smiley/steamcn_1/kbc35.gif': ':+:35'},
    {'https://keylol.com/static/image/smiley/steamcn_1/kbc36.gif': ':+:36'},
    {'https://keylol.com/static/image/smiley/steamcn_1/kbc37.gif': ':+:37'},
    {'https://keylol.com/static/image/smiley/steamcn_1/kbc38.gif': ':+:38'},
    {'https://keylol.com/static/image/smiley/steamcn_1/kbc39.gif': ':+:39'},
    {'https://keylol.com/static/image/smiley/steamcn_1/kbc40.gif': ':+:40'},
    {'https://keylol.com/static/image/smiley/steamcn_1/kbc41.gif': ':+:41'},
    {'https://keylol.com/static/image/smiley/steamcn_1/kbc42.gif': ':+:42'},
    {'https://keylol.com/static/image/smiley/steamcn_1/kbc43.gif': ':+:43'},
    {'https://keylol.com/static/image/smiley/steamcn_1/kbc44.gif': ':+:44'},
    {'https://keylol.com/static/image/smiley/steamcn_1/kbc45.gif': ':+:45'},
    {'https://keylol.com/static/image/smiley/steamcn_1/kbc46.gif': ':+:46'},
    {'https://keylol.com/static/image/smiley/steamcn_1/kbc47.gif': ':+:47'},
    {'https://keylol.com/static/image/smiley/steamcn_1/kbc48.gif': ':+:48'},
    {'https://keylol.com/static/image/smiley/steamcn_1/kbc49.gif': ':+:49'},
    {'https://keylol.com/static/image/smiley/steamcn_1/kbc50.gif': ':+:50'},
    {'https://keylol.com/static/image/smiley/steamcn_1/kbc51.gif': ':+:51'},
    {'https://keylol.com/static/image/smiley/steamcn_1/kbc86.gif': ':+:86'},
    {'https://keylol.com/static/image/smiley/steamcn_1/kbc87.gif': ':+:87'},
    {'https://keylol.com/static/image/smiley/steamcn_1/kbc54.gif': ':+:54'},
    {'https://keylol.com/static/image/smiley/steamcn_1/kbc85.gif': ':+:85'},
    {'https://keylol.com/static/image/smiley/steamcn_1/kbc57.gif': ':+:57'},
    {'https://keylol.com/static/image/smiley/steamcn_1/kbc59.gif': ':+:59'},
    {'https://keylol.com/static/image/smiley/steamcn_1/kbc60.gif': ':+:60'},
    {'https://keylol.com/static/image/smiley/steamcn_1/kbc61.gif': ':+:61'},
    {'https://keylol.com/static/image/smiley/steamcn_1/kbc62.gif': ':+:62'},
    {'https://keylol.com/static/image/smiley/steamcn_1/kbc63.gif': ':+:63'},
    {'https://keylol.com/static/image/smiley/steamcn_1/kbc64.gif': ':+:64'},
    {'https://keylol.com/static/image/smiley/steamcn_1/kbc65.gif': ':+:65'},
    {'https://keylol.com/static/image/smiley/steamcn_1/kbc66.gif': ':+:66'},
    {'https://keylol.com/static/image/smiley/steamcn_1/kbc67.gif': ':+:67'},
    {'https://keylol.com/static/image/smiley/steamcn_1/kbc68.gif': ':+:68'},
    {'https://keylol.com/static/image/smiley/steamcn_1/kbc69.gif': ':+:69'},
    {'https://keylol.com/static/image/smiley/steamcn_1/kbc70.gif': ':+:70'},
    {'https://keylol.com/static/image/smiley/steamcn_1/kbc100.gif': ':+:{糖葫芦}'},
    {
      'https://keylol.com/static/image/smiley/steamcn_1/kbc101.gif': ':+:{菊花好痒}'
    },
    {'https://keylol.com/static/image/smiley/steamcn_1/kbc102.gif': ':+:{挖鼻屎}'},
    {'https://keylol.com/static/image/smiley/steamcn_1/kbc103.gif': ':+:{踢腿}'},
    {'https://keylol.com/static/image/smiley/steamcn_1/kbc104.gif': ':+:{囧}'},
    {'https://keylol.com/static/image/smiley/steamcn_1/kbc105.gif': ':+:{帅}'},
    {'https://keylol.com/static/image/smiley/steamcn_1/kbc106.gif': ':+:{肿么了}'},
    {'https://keylol.com/static/image/smiley/steamcn_1/kbc107.gif': ':+:{必杀击}'}
  ],
  '杉果娘和圆子': [
    {
      'https://keylol.com/static/image/smiley/sonkwo/1%20(2).gif': '{:19_1059:}'
    },
    {
      'https://keylol.com/static/image/smiley/sonkwo/1%20(14).gif':
      '{:19_1060:}'
    },
    {
      'https://keylol.com/static/image/smiley/sonkwo/2%20(5).gif': '{:19_1061:}'
    },
    {
      'https://keylol.com/static/image/smiley/sonkwo/1%20(8).gif': '{:19_1062:}'
    },
    {
      'https://keylol.com/static/image/smiley/sonkwo/2%20(8).gif': '{:19_1063:}'
    },
    {
      'https://keylol.com/static/image/smiley/sonkwo/1%20(1).gif': '{:19_1064:}'
    },
    {
      'https://keylol.com/static/image/smiley/sonkwo/1%20(16).gif':
      '{:19_1065:}'
    },
    {
      'https://keylol.com/static/image/smiley/sonkwo/2%20(3).gif': '{:19_1066:}'
    },
    {
      'https://keylol.com/static/image/smiley/sonkwo/1%20(11).gif':
      '{:19_1067:}'
    },
    {
      'https://keylol.com/static/image/smiley/sonkwo/1%20(13).gif':
      '{:19_1068:}'
    },
    {
      'https://keylol.com/static/image/smiley/sonkwo/1%20(12).gif':
      '{:19_1069:}'
    },
    {
      'https://keylol.com/static/image/smiley/sonkwo/1%20(5).gif': '{:19_1070:}'
    },
    {
      'https://keylol.com/static/image/smiley/sonkwo/1%20(7).gif': '{:19_1071:}'
    },
    {
      'https://keylol.com/static/image/smiley/sonkwo/1%20(3).gif': '{:19_1072:}'
    },
    {
      'https://keylol.com/static/image/smiley/sonkwo/1%20(15).gif':
      '{:19_1073:}'
    },
    {
      'https://keylol.com/static/image/smiley/sonkwo/1%20(10).gif':
      '{:19_1074:}'
    },
    {
      'https://keylol.com/static/image/smiley/sonkwo/2%20(9).gif': '{:19_1075:}'
    },
    {
      'https://keylol.com/static/image/smiley/sonkwo/2%20(7).gif': '{:19_1076:}'
    },
    {
      'https://keylol.com/static/image/smiley/sonkwo/2%20(1).gif': '{:19_1077:}'
    },
    {
      'https://keylol.com/static/image/smiley/sonkwo/1%20(9).gif': '{:19_1078:}'
    },
    {
      'https://keylol.com/static/image/smiley/sonkwo/2%20(2).gif': '{:19_1079:}'
    },
    {
      'https://keylol.com/static/image/smiley/sonkwo/1%20(4).gif': '{:19_1080:}'
    },
    {
      'https://keylol.com/static/image/smiley/sonkwo/2%20(4).gif': '{:19_1081:}'
    },
    {
      'https://keylol.com/static/image/smiley/sonkwo/2%20(6).gif': '{:19_1082:}'
    },
    {'https://keylol.com/static/image/smiley/sonkwo/1%20(6).gif': '{:19_1083:}'}
  ]
};
