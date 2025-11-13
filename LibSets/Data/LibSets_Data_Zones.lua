--Check if the library was loaded before already w/o chat output
if IsLibSetsAlreadyLoaded(false) then return end

--This file the sets data and info (pre-loaded from the specified API version)
--It should be updated each time the APIversion increases to contain the new/changed data
local lib = LibSets

local tins = table.insert

lib.setDataPreloaded = lib.setDataPreloaded or {}
local setDataPreloaded = lib.setDataPreloaded


---------------------------------------------------------------------------------------------------------------------------
--Current APIversion is live or PTS check
local isPTSAPIVersionLive = lib.checkIfPTSAPIVersionIsLive()


------------------------------------------------------------------------------------------------------------------------
--> Last updated: API 101048, 2025-11-13, Baertram
------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------
--Remove wayshrines from the list where zoneIds are only available in newer APIversions
--Each line must be integer key without gaps (for ipairs) = zoneId, e.g.
--{
--  1207,
--  1208,
--}
local zoneIdsOfNewAPIVersionOnly = {
    --zoneIds not yet on live server - BEGIN
    --xxx APIVersion 10103x: xxxx

    --zoneIds of APIVersion 101046
    --[1] = xxxx, --zoneName here

    --zoneIds not yet on live server - END
}
lib.zoneIdsOfNewAPIVersionOnly = zoneIdsOfNewAPIVersionOnly
---------------------------------------------------------------------------------------------------------------------------


------------------------------------------------------------------------------------------------------------------------
    --The wayshrines's node index to their related zoneId
    --Coming from Excel file LibSets_SetData.xlsx, map "ESO dumped wayshrine info", colum J (generated lua code)
    setDataPreloaded[LIBSETS_TABLEKEY_WAYSHRINENODEID2ZONEID] = {[1]=3,[2]=3,[3]=3,[4]=3,[5]=3,[6]=3,[7]=3,[8]=3,[9]=20,[10]=20,[11]=20,[12]=20,[13]=20,[14]=19,[15]=19,[16]=19,[17]=19,[18]=19,[19]=19,[20]=3,[21]=383,[22]=19,[23]=19,[24]=57,[25]=57,[26]=57,[27]=57,[28]=57,[29]=57,[30]=57,[31]=19,[32]=57,[33]=92,[34]=92,[35]=92,[36]=92,[37]=92,[38]=92,[39]=92,[40]=92,[41]=41,[42]=104,[43]=104,[44]=104,[45]=104,[46]=104,[47]=117,[48]=117,[49]=117,[50]=117,[51]=117,[52]=117,[53]=117,[55]=20,[56]=19,[57]=104,[58]=104,[59]=104,[60]=104,[61]=104,[62]=3,[63]=92,[64]=3,[65]=41,[66]=41,[67]=41,[68]=41,[69]=41,[71]=41,[72]=41,[73]=41,[74]=41,[75]=41,[76]=41,[77]=41,[78]=117,[79]=57,[80]=57,[81]=57,[82]=20,[83]=20,[84]=20,[85]=117,[86]=20,[87]=101,[88]=101,[89]=101,[90]=101,[91]=101,[92]=101,[93]=101,[94]=101,[95]=101,[96]=101,[97]=101,[98]=41,[99]=58,[100]=58,[101]=58,[102]=58,[103]=58,[104]=58,[105]=58,[106]=58,[107]=58,[108]=41,[109]=103,[110]=103,[111]=103,[112]=103,[113]=103,[114]=103,[115]=103,[116]=103,[117]=103,[118]=103,[119]=103,[120]=103,[121]=381,[122]=381,[123]=381,[124]=381,[125]=281,[126]=281,[127]=381,[128]=347,[129]=347,[130]=347,[131]=347,[132]=347,[133]=347,[134]=347,[135]=347,[136]=347,[137]=104,[138]=534,[139]=347,[140]=347,[141]=537,[142]=537,[143]=108,[144]=382,[145]=347,[146]=347,[147]=108,[148]=108,[149]=108,[150]=108,[151]=108,[152]=108,[153]=108,[154]=108,[155]=104,[156]=382,[157]=382,[158]=382,[159]=382,[160]=382,[161]=382,[162]=382,[163]=382,[164]=383,[165]=383,[166]=383,[167]=383,[168]=383,[169]=383,[170]=181,[171]=117,[172]=280,[173]=281,[174]=381,[175]=381,[176]=381,[177]=381,[178]=381,[179]=534,[180]=534,[181]=535,[182]=535,[183]=535,[184]=347,[185]=382,[186]=92,[187]=103,[188]=58,[189]=19,[190]=20,[191]=383,[192]=117,[193]=3,[194]=381,[195]=101,[196]=104,[197]=108,[198]=57,[199]=181,[200]=181,[201]=181,[202]=181,[203]=181,[204]=92,[205]=57,[206]=92,[207]=383,[208]=20,[210]=3,[211]=381,[212]=41,[213]=383,[214]=383,[216]=3,[217]=888,[218]=888,[219]=888,[220]=888,[225]=888,[226]=888,[227]=888,[229]=888,[230]=888,[231]=888,[232]=888,[233]=888,[234]=888,[235]=888,[236]=181,[237]=684,[238]=684,[239]=684,[240]=684,[241]=684,[242]=684,[243]=684,[244]=684,[245]=684,[246]=684,[247]=181,[249]=684,[250]=684,[251]=823,[252]=823,[253]=823,[254]=823,[255]=816,[256]=816,[257]=816,[258]=382,[260]=117,[261]=117,[262]=381,[263]=19,[264]=57,[265]=383,[266]=41,[267]=3,[268]=108,[269]=20,[270]=888,[272]=849,[273]=849,[274]=849,[275]=849,[276]=849,[277]=849,[278]=849,[279]=849,[280]=849,[281]=849,[282]=849,[284]=849,[285]=381,[286]=104,[287]=57,[288]=381,[289]=3,[290]=41,[291]=382,[292]=3,[293]=41,[294]=58,[295]=281,[296]=383,[297]=3,[298]=41,[299]=58,[300]=537,[301]=103,[302]=19,[303]=92,[304]=108,[305]=117,[306]=108,[307]=20,[309]=57,[310]=888,[311]=382,[312]=101,[313]=92,[314]=104,[315]=381,[316]=117,[317]=383,[318]=19,[319]=57,[320]=382,[321]=382,[322]=103,[323]=92,[324]=534,[325]=383,[326]=888,[327]=888,[328]=849,[329]=849,[330]=849,[331]=849,[332]=888,[333]=849,[334]=849,[335]=849,[336]=849,[337]=980,[338]=980,[339]=980,[340]=980,[341]=92,[342]=3,[343]=823,[344]=347,[345]=888,[346]=980,[347]=980,[348]=684,[349]=1011,[350]=1011,[351]=1011,[352]=1011,[353]=1011,[354]=1011,[355]=1011,[356]=1011,[357]=1011,[358]=1011,[359]=1011,[360]=1027,[361]=816,[362]=823,[363]=19,[364]=1011,[365]=1011,[366]=1011,[367]=1011,[368]=1011,[369]=1011,[370]=108,[371]=382,[372]=103,[373]=1027,[374]=726,[375]=726,[376]=726,[377]=726,[378]=726,[379]=726,[380]=101,[381]=1086,[382]=1086,[383]=1086,[384]=1086,[386]=1086,[387]=1086,[388]=726,[389]=101,[390]=823,[391]=1086,[392]=101,[395]=888,[396]=1086,[397]=1086,[398]=383,[399]=1086,[400]=1086,[401]=1086,[402]=1133,[403]=1133,[404]=1133,[405]=1133,[406]=1133,[407]=1133,[409]=20,[410]=1086,[411]=0,[412]=0,[413]=0,[414]=0,[415]=1160,[416]=1160,[417]=1160,[418]=1160,[419]=1160,[420]=1160,[421]=1160,[422]=1133,[423]=1133,[424]=684,[425]=92,[426]=1160,[427]=92,[428]=684,[429]=1160,[430]=0,[431]=0,[432]=0,[433]=0,[434]=1160,[435]=0,[436]=1160,[437]=823,[438]=1160,[439]=1160,[440]=0,[441]=1207,[442]=1207,[443]=1207,[444]=1207,[445]=1207,[446]=0,[447]=1207,[448]=0,[449]=1207,[450]=1160,[451]=1160,[452]=1160,[453]=1160,[454]=57,[455]=1160,[456]=1207,[457]=1207,[458]=1261,[459]=1261,[460]=1261,[461]=1261,[462]=1261,[463]=1261,[464]=1261,[465]=849,[466]=823,[467]=1261,[468]=1261,[469]=1261,[470]=3,[471]=1261,[472]=1261,[473]=1261,[476]=1286,[477]=1286,[478]=1286,[479]=1286,[480]=1286,[481]=1261,[482]=1261,[483]=1261,[484]=1261,[485]=58,[486]=1261,[487]=1283,[488]=1318,[489]=1283,[490]=1286,[491]=1286,[493]=1283,[494]=1286,[495]=1283,[496]=1286,[497]=1011,[498]=20,[499]=535,[501]=1318,[502]=1318,[503]=1318,[504]=1318,[505]=1318,[506]=1318,[507]=1318,[508]=1318,[509]=1318,[510]=1318,[511]=1318,[512]=1318,[513]=1318,[517]=1318,[518]=1318,[519]=1318,[520]=1318,[521]=1318,[522]=1318,[523]=1318,[524]=1383,[525]=1383,[526]=1383,[527]=1383,[528]=1383,[529]=1383,[530]=1383,[531]=41,[532]=103,[533]=1318,[534]=1414,[535]=1414,[536]=1414,[537]=1414,[538]=1414,[539]=1414,[540]=1413,[541]=1413,[542]=1413,[543]=1413,[544]=1413,[545]=1413,[546]=1413,[547]=1413,[548]=1413,[549]=1414,[550]=1413,[551]=1383,[552]=1414,[553]=1414,[554]=1414,[555]=1414,[556]=1207,[557]=980,[558]=1443,[559]=1443,[560]=1443,[561]=1443,[562]=1443,[563]=1443,[564]=1443,[565]=684,[566]=1383,[567]=1413,[568]=1443,[573]=1443,[574]=1443,[575]=1443,[577]=1443,[578]=1443,[579]=1443,[580]=1443,[581]=1443,[582]=816,[583]=1443,[584]=1443,[585]=381,[586]=1443,[587]=0,[588]=103,[589]=1502,[590]=1282,[591]=1443,[592]=1502,[593]=1502,[594]=1502,[595]=1502,[596]=1502,[597]=1502,[598]=1502,[599]=1502,[601]=1502,[605]=1502,[606]=1502,[607]=1502,[608]=1502,[609]=1502,[610]=1502,[611]=1502,[612]=1502,[614]=1502,[615]=1502}
    --LIBSETS_TABLEKEY_WAYSHRINENODEID2ZONEID



------------------------------------------------------------------------------------------------------------------------
    --The preloaded zoneIds of dungeons, and their parent zoneIds, plus the dungeionFinderId and Indices, and their motif/nodeath/speedrun/hardmode/trifecta achievementIds
    setDataPreloaded[LIBSETS_TABLEKEY_DUNGEON_ZONE_MAPPING] = {
        [638]={parentZoneId=888,isTrial=true},   --Aetherian Archive
        [148]={parentZoneId=117,dungeonFinderId={[false]=8,[true]=305},achievementId={[false]=272,[true]=1604},hardMode=1609,speedRun=1607,noDeath=1608,wayshrine=192},   --Arx Corinium
        [1000]={parentZoneId=980,isTrial=true},   --Asylum Sanctorium
        [1389]={parentZoneId=41,isTrial=true,dungeonFinderId={[false]=613,[true]=614},achievementId={[false]=3468,[true]=3469},motif=3547,hardMode=3470,speedRun=3471,noDeath=3472,trifecta=3474,wayshrine=531},   --Bal Sunnar
        [1471]={parentZoneId=684,dungeonFinderId={[false]=640,[true]=641},achievementId={[false]=3851,[true]=3852},motif=3922,hardMode=3853,speedRun=3854,noDeath=3855,trifecta=3857,wayshrine=565},   --Bedlam Veil
        [1228]={parentZoneId=823,dungeonFinderId={[false]=591,[true]=592},achievementId={[false]=2831,[true]=2832},motif=2984,hardMode=2833,speedRun=2834,noDeath=2835,trifecta=2838,wayshrine=437},   --Black Drake Villa
        [1552]={parentZoneId=1502,dungeonFinderId={[false]=1039,[true]=1040},achievementId={[false]=4334,[true]=4335},hardMode=4336,speedRun=4337,noDeath=4338,trifecta=4340,wayshrine=605},   --Black Gem Foundry
        [38]={parentZoneId=92,dungeonFinderId={[false]=15,[true]=321},achievementId={[false]=410,[true]=1647},hardMode=1652,speedRun=1650,noDeath=1651,wayshrine=186},   --Blackheart Haven
        [64]={parentZoneId=103,dungeonFinderId={[false]=14,[true]=320},achievementId={[false]=393,[true]=1641},hardMode=1646,speedRun=1644,noDeath=1645,wayshrine=187},   --Blessed Crucible
        [973]={parentZoneId=888,dungeonFinderId={[false]=324,[true]=325},achievementId={[false]=1690,[true]=1691},motif=2098,hardMode=1696,speedRun=1694,noDeath=1695,wayshrine=326},   --Bloodroot Forge
        [1201]={parentZoneId=1160,dungeonFinderId={[false]=509,[true]=510},achievementId={[false]=2704,[true]=2705},motif=2849,hardMode=2706,speedRun=2707,noDeath=2708,trifecta=2710,wayshrine=436},   --Castle Thorn
        [176]={parentZoneId=108,dungeonFinderId={[false]=10,[true]=310},achievementId={[false]=551,[true]=1597},hardMode=1602,speedRun=1600,noDeath=1601,wayshrine=197},   --City of Ash I
        [681]={parentZoneId=108,dungeonFinderId={[false]=322,[true]=267},achievementId={[false]=1603,[true]=878},hardMode=1114,speedRun=1108,noDeath=1107,wayshrine=268},   --City of Ash II
        [1051]={parentZoneId=1011,isTrial=true},   --Cloudrest
        [1301]={parentZoneId=1011,dungeonFinderId={[false]=599,[true]=600},achievementId={[false]=3104,[true]=3105},motif=3229,hardMode=3153,speedRun=3107,noDeath=3108,trifecta=3111,wayshrine=497},   --Coral Aerie
        [848]={parentZoneId=117,dungeonFinderId={[false]=295,[true]=296},achievementId={[false]=1522,[true]=1523},motif=1796,hardMode=1524,speedRun=1525,noDeath=1526,wayshrine=261},   --Cradle of Shadows
        [130]={parentZoneId=20,dungeonFinderId={[false]=9,[true]=261},achievementId={[false]=80,[true]=1610},hardMode=1615,speedRun=1613,noDeath=1614,wayshrine=190},   --Crypt of Hearts I
        [932]={parentZoneId=20,dungeonFinderId={[false]=317,[true]=318},achievementId={[false]=1616,[true]=876},hardMode=1084,speedRun=941,noDeath=942,wayshrine=269},   --Crypt of Hearts II
        [63]={parentZoneId=57,dungeonFinderId={[false]=5,[true]=309},achievementId={[false]=78,[true]=1581},hardMode=1586,speedRun=1584,noDeath=1585,wayshrine=198},   --Darkshade Caverns I
        [930]={parentZoneId=57,dungeonFinderId={[false]=308,[true]=21},achievementId={[false]=1587,[true]=464},hardMode=467,speedRun=465,noDeath=1588,wayshrine=264},   --Darkshade Caverns II
        [1081]={parentZoneId=823,dungeonFinderId={[false]=435,[true]=436},achievementId={[false]=2270,[true]=2271},motif=2504,hardMode=2272,speedRun=2273,noDeath=2274,trifecta=2276,wayshrine=390},   --Depths of Malatar
        [449]={parentZoneId=101,dungeonFinderId={[false]=11,[true]=319},achievementId={[false]=357,[true]=1623},hardMode=1628,speedRun=1626,noDeath=1627,wayshrine=195},   --Direfrost Keep
        [1268]={parentZoneId=1261,dungeonFinderId={[false]=597,[true]=598},achievementId={[false]=3026,[true]=3027},motif=3094,hardMode=3028,speedRun=3029,noDeath=3030,trifecta=3032,wayshrine=469},   --The Dread Cellar
        [1344]={parentZoneId=1318,isTrial=true},   --Dreadsail Reef
        [1360]={parentZoneId=1318,dungeonFinderId={[false]=608,[true]=609},achievementId={[false]=3375,[true]=3376},motif=3422,hardMode=3377,speedRun=3378,noDeath=3379,trifecta=3381,wayshrine=520},   --Earthen Root Enclave
        [126]={parentZoneId=383,dungeonFinderId={[false]=7,[true]=23},achievementId={[false]=11,[true]=1573},hardMode=1578,speedRun=1576,noDeath=1577,wayshrine=191},   --Elden Hollow I
        [931]={parentZoneId=383,dungeonFinderId={[false]=303,[true]=302},achievementId={[false]=1579,[true]=459},hardMode=463,speedRun=461,noDeath=1580,wayshrine=265},   --Elden Hollow II
        [1436]={parentZoneId=1413},   --Infinite Archive
        [1496]={parentZoneId=1443,dungeonFinderId={[false]=855,[true]=856},achievementId={[false]=4109,[true]=4110},motif=4159,hardMode=4111,speedRun=4112,noDeath=4113,trifecta=4115,wayshrine=581},   --Exiled Redoubt
        [974]={parentZoneId=888,dungeonFinderId={[false]=368,[true]=369},achievementId={[false]=1698,[true]=1699},motif=2097,hardMode=1704,speedRun=1702,noDeath=1703,wayshrine=332},   --Falkreath Hold
        [1009]={parentZoneId=92,dungeonFinderId={[false]=420,[true]=421},achievementId={[false]=1959,[true]=1960},motif=2190,hardMode=1965,speedRun=1963,noDeath=1964,trifecta=2102,wayshrine=341},   --Fang Lair
        [1080]={parentZoneId=101,dungeonFinderId={[false]=433,[true]=434},achievementId={[false]=2260,[true]=2261},motif=2503,hardMode=2262,speedRun=2263,noDeath=2264,trifecta=2267,wayshrine=389},   --Frostvault
        [283]={parentZoneId=41,dungeonFinderId={[false]=2,[true]=299},achievementId={[false]=294,[true]=1556},hardMode=1561,speedRun=1559,noDeath=1560,wayshrine=98},   --Fungal Grotto I
        [934]={parentZoneId=41,dungeonFinderId={[false]=18,[true]=312},achievementId={[false]=1562,[true]=343},hardMode=342,speedRun=340,noDeath=1563,wayshrine=266},   --Fungal Grotto II
        [1361]={parentZoneId=1318,dungeonFinderId={[false]=610,[true]=611},achievementId={[false]=3394,[true]=3395},motif=3423,hardMode=3396,speedRun=3397,noDeath=3398,trifecta=3400,wayshrine=521},   --Graven Deep
        [975]={parentZoneId=849,isTrial=true},   --Halls of Fabrication
        [636]={parentZoneId=888,isTrial=true},   --Hel Ra Citadel
        [1152]={parentZoneId=684,dungeonFinderId={[false]=503,[true]=504},achievementId={[false]=2539,[true]=2540},motif=2747,hardMode=2541,speedRun=2542,noDeath=2543,trifecta=2546,wayshrine=424},   --Icereach
        [678]={parentZoneId=584,dungeonFinderId={[false]=289,[true]=268},achievementId={[false]=1345,[true]=880},hardMode=1303,speedRun=1128,noDeath=1129,wayshrine=236},   --Imperial City Prison
        [1196]={parentZoneId=1160},   --Kyne's Aegis
        [1123]={parentZoneId=383,dungeonFinderId={[false]=496,[true]=497},achievementId={[false]=2425,[true]=2426},motif=2629,hardMode=2427,speedRun=2428,noDeath=2429,trifecta=2431,wayshrine=398},   --Lair of Maarselok
        [1497]={parentZoneId=816,dungeonFinderId={[false]=857,[true]=858},achievementId={[false]=4128,[true]=4129},motif=4160,hardMode=4130,speedRun=4131,noDeath=4132,trifecta=4134,wayshrine=582},   --Lep Seclusa
        [1478]={parentZoneId=1443,isTrial=true},   --Lucent Citadel
        [1055]={parentZoneId=108,dungeonFinderId={[false]=428,[true]=429},achievementId={[false]=2162,[true]=2163},motif=2317,hardMode=2164,speedRun=2165,noDeath=2166,trifecta=2168,wayshrine=370},   --March of Sacrifices
        [725]={parentZoneId=816,isTrial=true},   --Maw of Lorkhaj
        [1052]={parentZoneId=382,dungeonFinderId={[false]=426,[true]=427},achievementId={[false]=2152,[true]=2153},motif=2318,hardMode=2154,speedRun=2155,noDeath=2156,trifecta=2159,wayshrine=371},   --Moon Hunter Keep
        [1122]={parentZoneId=1086,dungeonFinderId={[false]=494,[true]=495},achievementId={[false]=2415,[true]=2416},motif=2628,hardMode=2417,speedRun=2418,noDeath=2419,trifecta=2422,wayshrine=391},   --Moongrave Fane
        [1551]={parentZoneId=1502,dungeonFinderId={[false]=1037,[true]=1038},achievementId={[false]=4311,[true]=4312},hardMode=4313,speedRun=4314,noDeath=4315,trifecta=4317,wayshrine=606},   --Naj-Caldeesh
        [1470]={parentZoneId=1207,dungeonFinderId={[false]=638,[true]=639},achievementId={[false]=3810,[true]=3811},motif=3921,hardMode=3812,speedRun=3813,noDeath=3814,trifecta=3816,wayshrine=556},   --Oathsworn Pit
        [1548]={parentZoneId=1502,isTrial=true},   --Ossein Cage
        [1267]={parentZoneId=3,dungeonFinderId={[false]=595,[true]=596},achievementId={[false]=3016,[true]=3017},motif=3097,hardMode=3018,speedRun=3019,noDeath=3020,trifecta=3023,wayshrine=470},   --Red Petal Bastion
        [843]={parentZoneId=117,dungeonFinderId={[false]=293,[true]=294},achievementId={[false]=1504,[true]=1505},motif=1795,hardMode=1506,speedRun=1507,noDeath=1508,wayshrine=260},   --Ruins of Mazzatun
        [639]={parentZoneId=888,isTrial=true},   --Sanctum Ophidia
        [1427]={parentZoneId=1414,isTrial=true},   --Sanity's Edge
        [1010]={parentZoneId=19,dungeonFinderId={[false]=418,[true]=419},achievementId={[false]=1975,[true]=1976},motif=2189,hardMode=1981,speedRun=1979,noDeath=1980,trifecta=1983,wayshrine=363},   --Scalecaller Peak
        [1390]={parentZoneId=103,dungeonFinderId={[false]=615,[true]=616},achievementId={[false]=3529,[true]=3530},motif=3546,hardMode=3531,speedRun=3532,noDeath=3533,trifecta=3535,wayshrine=532},   --Scrivener's Hall
        [31]={parentZoneId=382,dungeonFinderId={[false]=16,[true]=313},achievementId={[false]=417,[true]=1635},hardMode=1640,speedRun=1638,noDeath=1639,wayshrine=185},   --Selene's Web
        [1302]={parentZoneId=20,dungeonFinderId={[false]=601,[true]=602},achievementId={[false]=3114,[true]=3115},motif=3228,hardMode=3154,speedRun=3117,noDeath=3118,trifecta=3120,wayshrine=498},   --Shipwright's Regret
        [144]={parentZoneId=3,dungeonFinderId={[false]=3,[true]=315},achievementId={[false]=301,[true]=1565},hardMode=1570,speedRun=1568,noDeath=1569,wayshrine=193},   --Spindleclutch I
        [936]={parentZoneId=3,dungeonFinderId={[false]=316,[true]=19},achievementId={[false]=1571,[true]=421},hardMode=448,speedRun=446,noDeath=1572,wayshrine=267},   --Spindleclutch II
        [1197]={parentZoneId=1161,dungeonFinderId={[false]=507,[true]=508},achievementId={[false]=2694,[true]=2695},motif=2850,hardMode=2755,speedRun=2697,noDeath=2698,trifecta=2701,wayshrine=435},   --Stone Garden
        [1121]={parentZoneId=1086,isTrial=true},   --Sunspire
        [131]={parentZoneId=58,dungeonFinderId={[false]=13,[true]=311},achievementId={[false]=81,[true]=1617},hardMode=1622,speedRun=1620,noDeath=1621,wayshrine=188},   --Tempest Island
        [380]={parentZoneId=381,dungeonFinderId={[false]=4,[true]=20},achievementId={[false]=325,[true]=1549},hardMode=1554,speedRun=1552,noDeath=1553,wayshrine=198},   --The Banished Cells I
        [935]={parentZoneId=381,dungeonFinderId={[false]=300,[true]=301},achievementId={[false]=1555,[true]=545},hardMode=451,speedRun=449,noDeath=1564,wayshrine=262},   --The Banished Cells II
        [1229]={parentZoneId=57,dungeonFinderId={[false]=593,[true]=594},achievementId={[false]=2841,[true]=2842},motif=2991,hardMode=2843,speedRun=2844,noDeath=2845,trifecta=2847,wayshrine=454},   --The Cauldron
        [1153]={parentZoneId=92,dungeonFinderId={[false]=505,[true]=506},achievementId={[false]=2549,[true]=2550},motif=2749,hardMode=2551,speedRun=2552,noDeath=2553,trifecta=2555,wayshrine=425},   --Unhallowed Grave
        [11]={parentZoneId=347,dungeonFinderId={[false]=17,[true]=314},achievementId={[false]=570,[true]=1653},hardMode=1658,speedRun=1656,noDeath=1657,wayshrine=184},   --Vaults of Madness
        [22]={parentZoneId=104,dungeonFinderId={[false]=12,[true]=304},achievementId={[false]=391,[true]=1629},hardMode=1634,speedRun=1632,noDeath=1633,wayshrine=196},   --Volenfell
        [146]={parentZoneId=19,dungeonFinderId={[false]=6,[true]=306},achievementId={[false]=79,[true]=1589},hardMode=1594,speedRun=1592,noDeath=1593,wayshrine=189},   --Wayrest Sewers I
        [933]={parentZoneId=19,dungeonFinderId={[false]=22,[true]=307},achievementId={[false]=1595,[true]=678},hardMode=681,speedRun=679,noDeath=1596,wayshrine=263},   --Wayrest Sewers II
        [688]={parentZoneId=584,dungeonFinderId={[false]=288,[true]=287},achievementId={[false]=1346,[true]=1120},hardMode=1279,speedRun=1275,noDeath=1276,wayshrine=247},   --White-Gold Tower
    }

------------------------------------------------------------------------------------------------------------------------
    --The preloaded zoneIds of public dungeons, and their parent zoneIds
    setDataPreloaded[LIBSETS_TABLEKEY_PUBLICDUNGEON_ZONE_MAPPING] = {
        [284]={parentZoneId=3, DLCID=DLC_BASE_GAME},   --Bad Man's Hallows
        [142]={parentZoneId=19, DLCID=DLC_BASE_GAME},   --Bonesnap Ruins
        [138]={parentZoneId=58, DLCID=DLC_BASE_GAME},   --Crimson Cove
        [216]={parentZoneId=41, DLCID=DLC_BASE_GAME},   --Crow's Wood
        [306]={parentZoneId=57, DLCID=DLC_BASE_GAME},   --Forgotten Crypts
        [339]={parentZoneId=101, DLCID=DLC_BASE_GAME},   --Hall of the Dead
        [308]={parentZoneId=104, DLCID=DLC_BASE_GAME},   --Lost City of the Na-Totambu
        [162]={parentZoneId=20, DLCID=DLC_BASE_GAME},   --Obsidian Scar
        [169]={parentZoneId=92, DLCID=DLC_BASE_GAME},   --Razak's Wheel
        [124]={parentZoneId=383, DLCID=DLC_BASE_GAME},   --Root Sunder Ruins
        [137]={parentZoneId=108, DLCID=DLC_BASE_GAME},   --Rulanyil's Fall
        [134]={parentZoneId=117, DLCID=DLC_BASE_GAME},   --Sanguine's Demesne
        [341]={parentZoneId=103, DLCID=DLC_BASE_GAME},   --The Lion's Den
        [487]={parentZoneId=382, DLCID=DLC_BASE_GAME},   --The Vile Manse
        [486]={parentZoneId=381, DLCID=DLC_BASE_GAME},   --Toothmaul Gully
        [557]={parentZoneId=347, DLCID=DLC_BASE_GAME},   --Village of the Lost
        [706]={parentZoneId=684, DLCID=DLC_ORSINIUM},   --Old Orsinium
        [705]={parentZoneId=684, DLCID=DLC_ORSINIUM},   --Rkindaleft
        [919]={parentZoneId=849, DLCID=DLC_MORROWIND},   --Forgotten Wastes
        [918]={parentZoneId=849, DLCID=DLC_MORROWIND},   --Nchuleftingth
        [1020]={parentZoneId=1011, DLCID=DLC_SUMMERSET},   --Karnwasten
        [1021]={parentZoneId=1011, DLCID=DLC_SUMMERSET},   --Sunhold
        [1090]={parentZoneId=1086, DLCID=DLC_ELSWEYR},   --Orcrest
        [1089]={parentZoneId=1086, DLCID=DLC_ELSWEYR},   --Rimmen Necropolis
        [1186]={parentZoneId=1160, DLCID=DLC_GREYMOOR},   --Labyrinthian
        [1187]={parentZoneId=1161, DLCID=DLC_GREYMOOR},   --Nchuthnkarst
        [1260]={parentZoneId=1261, DLCID=DLC_BLACKWOOD},   --The Silent Halls
        [1259]={parentZoneId=1261, DLCID=DLC_BLACKWOOD},   --Zenithar's Abbey
        [1310]={parentZoneId=1286, DLCID=DLC_DEADLANDS},   --Atoll of Immolation
        [1337]={parentZoneId=1318, DLCID=DLC_HIGH_ISLE},   --Spire of the Crimson Coin
        [1338]={parentZoneId=1318, DLCID=DLC_HIGH_ISLE},   --Ghost Haven Bay
        [1415]={parentZoneId=1414, DLCID=DLC_NECROM},   --Gorne
        [1416]={parentZoneId=1413, DLCID=DLC_NECROM},   --The Underweave
        [1467]={parentZoneId=1443, DLCID=DLC_GOLD_ROAD},   --Silorn
        [1466]={parentZoneId=1443, DLCID=DLC_GOLD_ROAD},   --Leftwheal Trading Post
        [1530]={parentZoneId=1502, DLCID=DLC_SEASONS_OF_THE_WORMCULT2},   --Calindvale Gardens
    }

------------------------------------------------------------------------------------------------------------------------
    --The preloaded mapping between the ESO ingame set item collection tree-view (parent zone, zone, sets in zone) and
    --the zoneIds of the mappable zones
    --The table contains the setItemCollection parentCategoryId -> their subCategories as table, flags if those are a
    --dungeon, trial, arena
    --If zoneIds can be mapped to them there will be a zoneId sub-table entry as well! Some of the entries cannot be
    --mapped to zoneIds so they will miss that sub-table!
    setDataPreloaded[LIBSETS_TABLEKEY_SET_ITEM_COLLECTIONS_ZONE_MAPPING] =
    {
        --Special Category at the top
        { parentCategory=124, category=130, zoneIds={1502}},--Solstice
        --Aldmeri-Dominion
        { parentCategory=1, category=11, zoneIds={381}},--Auridon
        { parentCategory=1, category=12, zoneIds={383}},--Grahtwood
        { parentCategory=1, category=13, zoneIds={108}},--Greenshade
        { parentCategory=1, category=14, zoneIds={58}},--Malabal Tor
        { parentCategory=1, category=15, zoneIds={382}},--Reaper's March
        --Daggerfall-Convenion
        { parentCategory=2, category=16, zoneIds={104}},--Alik'r Desert
        { parentCategory=2, category=17, zoneIds={92}},--Bangkorai
        { parentCategory=2, category=18, zoneIds={3}},--Glenumbra
        { parentCategory=2, category=19, zoneIds={20}},--Rivenspire
        { parentCategory=2, category=20, zoneIds={19}},--Stormhaven
        --Ebonheart Pact
        { parentCategory=3, category=21, zoneIds={57}},--Deshaan
        { parentCategory=3, category=22, zoneIds={101}},--Eastmarch
        { parentCategory=3, category=23, zoneIds={103}},--The Rift
        { parentCategory=3, category=24, zoneIds={117}},--Shadowfen
        { parentCategory=3, category=25, zoneIds={41}},--Stonefalls
        --Infinite Archive
        { parentCategory=109, category=117, zoneIds={1436}},--All classes
        --DLC-Regions
        { parentCategory=4, category=29, zoneIds={684}},--Wrothgar
        { parentCategory=4, category=30, zoneIds={816}},--Hew's Bane
        { parentCategory=4, category=31, zoneIds={823}},--Gold Coast
        { parentCategory=4, category=32, zoneIds={849}},--Vvardenfell
        { parentCategory=4, category=33, zoneIds={980,981}},--Clockwork City/Brass Fortress
        { parentCategory=4, category=34, zoneIds={1011,1027}},--Summerset/Artaeum
        { parentCategory=4, category=35, zoneIds={726}},--Murkmire
        { parentCategory=4, category=36, zoneIds={1086}},--Northern Elsweyr
        { parentCategory=4, category=37, zoneIds={1133}},--Southern Elsweyr
        { parentCategory=4, category=38, zoneIds={1160,1161}},--Western Skyrim/Blackreach: Greymoor Caverns
        { parentCategory=4, category=89, zoneIds={1207,1208}},--The Reach/Blackreach: Arkthzand Cavern
        { parentCategory=4, category=93, zoneIds={1261}},--Blackwood
        { parentCategory=4, category=97, zoneIds={1286,1282,1283}},--The Deadlands/Fargrave/The Shambles
        { parentCategory=4, category=100, zoneIds={1318}},--High Isle
        { parentCategory=4, category=104, zoneIds={1383}},--Galen
        { parentCategory=4, category=107, zoneIds={1413,1414}},--Apocrypha/Telvanni Peninsula
        { parentCategory=4, category=130, zoneIds={1502}},--Solstice
        --Dungeons
        { parentCategory=5, category=39, zoneIds={148}, isDungeon=true},--Arx Corinium
        { parentCategory=5, category=40, zoneIds={380,935}, isDungeon=true},--The Banished Cells I
        { parentCategory=5, category=41, zoneIds={38}, isDungeon=true},--Blackheart Haven
        { parentCategory=5, category=42, zoneIds={64}, isDungeon=true},--Blessed Crucible
        { parentCategory=5, category=43, zoneIds={176,681}, isDungeon=true},--City of Ash I
        { parentCategory=5, category=44, zoneIds={130,932}, isDungeon=true},--Crypt of Hearts I
        { parentCategory=5, category=45, zoneIds={63,930}, isDungeon=true},--Darkshade Caverns I
        { parentCategory=5, category=46, zoneIds={449}, isDungeon=true},--Direfrost Keep
        { parentCategory=5, category=47, zoneIds={126,931}, isDungeon=true},--Elden Hollow I
        { parentCategory=5, category=48, zoneIds={283,934}, isDungeon=true},--Fungal Grotto I
        { parentCategory=5, category=49, zoneIds={31}, isDungeon=true},--Selene's Web
        { parentCategory=5, category=50, zoneIds={144,936}, isDungeon=true},--Spindleclutch I
        { parentCategory=5, category=51, zoneIds={131}, isDungeon=true},--Tempest Island
        { parentCategory=5, category=52, zoneIds={11}, isDungeon=true},--Vaults of Madness
        { parentCategory=5, category=53, zoneIds={22}, isDungeon=true},--Volenfell
        { parentCategory=5, category=54, zoneIds={146,933}, isDungeon=true},--Wayrest Sewers I
        --DLC-Dungeons
        { parentCategory=6, category=55, zoneIds={678}, isDungeon=true},--Imperial City Prison
        { parentCategory=6, category=56, zoneIds={688}, isDungeon=true},--White-Gold Tower
        { parentCategory=6, category=57, zoneIds={848}, isDungeon=true},--Cradle of Shadows
        { parentCategory=6, category=58, zoneIds={843}, isDungeon=true},--Ruins of Mazzatun
        { parentCategory=6, category=59, zoneIds={973}, isDungeon=true},--Bloodroot Forge
        { parentCategory=6, category=60, zoneIds={974}, isDungeon=true},--Falkreath Hold
        { parentCategory=6, category=61, zoneIds={1009}, isDungeon=true},--Fang Lair
        { parentCategory=6, category=62, zoneIds={1010}, isDungeon=true},--Scalecaller Peak
        { parentCategory=6, category=63, zoneIds={1055}, isDungeon=true},--March of Sacrifices
        { parentCategory=6, category=64, zoneIds={1052}, isDungeon=true},--Moon Hunter Keep
        { parentCategory=6, category=65, zoneIds={1081}, isDungeon=true},--Depths of Malatar
        { parentCategory=6, category=66, zoneIds={1080}, isDungeon=true},--Frostvault
        { parentCategory=6, category=67, zoneIds={1123}, isDungeon=true},--Lair of Maarselok
        { parentCategory=6, category=68, zoneIds={1122}, isDungeon=true},--Moongrave Fane
        { parentCategory=6, category=69, zoneIds={1152}, isDungeon=true},--Icereach
        { parentCategory=6, category=70, zoneIds={1153}, isDungeon=true},--Unhallowed Grave
        { parentCategory=6, category=87, zoneIds={1201}, isDungeon=true},--Castle Thorn
        { parentCategory=6, category=88, zoneIds={1197}, isDungeon=true},--Stone Garden
        { parentCategory=6, category=91, zoneIds={1228}, isDungeon=true},--Black Drake Villa
        { parentCategory=6, category=92, zoneIds={1229}, isDungeon=true},--The Cauldron
        { parentCategory=6, category=95, zoneIds={1268}, isDungeon=true},--Dread Cellar
        { parentCategory=6, category=96, zoneIds={1267}, isDungeon=true},--Red Petal Bastion
        { parentCategory=6, category=98, zoneIds={1301}, isDungeon=true},--Coral Aerie
        { parentCategory=6, category=99, zoneIds={1302}, isDungeon=true},--Shipwright's Regret
        { parentCategory=6, category=102, zoneIds={1360}, isDungeon=true},--Earthen Root Enclave
        { parentCategory=6, category=103, zoneIds={1361}, isDungeon=true},--Graven Deep
        { parentCategory=6, category=105, zoneIds={1389}, isDungeon=true},--Bal Sunnar
        { parentCategory=6, category=106, zoneIds={1390}, isDungeon=true},--Scrivener's Hall
        { parentCategory=6, category=110, zoneIds={1470}, isDungeon=true},--Oathsworn Pit
        { parentCategory=6, category=111, zoneIds={1471}, isDungeon=true},--Bedlam Veil
        { parentCategory=6, category=127, zoneIds={1496}, isDungeon=true},--Exiled Redoubt
        { parentCategory=6, category=128, zoneIds={1497}, isDungeon=true},--Lep Seclusa
        { parentCategory=6, category=132, zoneIds={1551}, isDungeon=true},--Naj-Caldeesh
        { parentCategory=6, category=129, zoneIds={1552}, isDungeon=true},--Black Gem Foundry
        --Trials
        { parentCategory=7, category=71, zoneIds={638}, isTrial=true},--Aetherian Archive
        { parentCategory=7, category=72, zoneIds={636}, isTrial=true},--Hel Ra Citadel
        { parentCategory=7, category=73, zoneIds={639}, isTrial=true},--Sanctum Ophidia
        { parentCategory=7, category=74, zoneIds={725}, isTrial=true},--Maw of Lorkhaj
        { parentCategory=7, category=75, zoneIds={975}, isTrial=true},--Halls of Fabrication
        { parentCategory=7, category=76, zoneIds={1000}, isTrial=true},--Asylum Sanctorium
        { parentCategory=7, category=77, zoneIds={1051}, isTrial=true},--Cloudrest
        { parentCategory=7, category=78, zoneIds={1121}, isTrial=true},--Sunspire
        { parentCategory=7, category=79, zoneIds={1196}, isTrial=true},--Kyne's Aegis
        { parentCategory=7, category=101, zoneIds={1344}, isTrial=true},--Dreadsail Reef
        { parentCategory=7, category=108, zoneIds={1427}, isTrial=true},--Sanity's Edge
        { parentCategory=7, category=125, zoneIds={1478}, isTrial=true},--Lucent Citadel
        { parentCategory=7, category=131, zoneIds={1548}, isTrial=true},--Ossein Cage
        --Arenas
        { parentCategory=8, category=80, zoneIds={635}, isArena=true},--Dragonstar Arena
        { parentCategory=8, category=81, zoneIds={677}, isArena=true},--Maelstrom Arena
        { parentCategory=8, category=82, zoneIds={1082}, isArena=true},--Blackrose Prison
        { parentCategory=8, category=90, zoneIds={1227}, isArena=true},--Vateshran Hollows
        --PVP
        { parentCategory=9, category=83, zoneIds={181}},--Cyrodiil
        { parentCategory=9, category=84, zoneIds={584}},--Imperial City
        { parentCategory=9, category=85},--Battlegrounds
        --Miscellaneous
        { parentCategory=10, category=26, zoneIds={280,281,534,535,537}},--Beginner zones
        { parentCategory=10, category=27, zoneIds={347}},--Coldharbour
        { parentCategory=10, category=28, zoneIds={888}},--Craglorn
        { parentCategory=10, category=86},--Antiquities
    } --LIBSETS_TABLEKEY_SET_ITEM_COLLECTIONS_ZONE_MAPPING


------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
--Entries to the setItemCollection mappings which are APIversion dependent
local mappingForSetItemCollectionsNotYetLive = {
    --[[
        --EXAMPLE
        { parentCategory=6, category=91, zoneIds={1228}, isDungeon=true},--Black Drake Villa
        { parentCategory=6, category=92, zoneIds={1229}, isDungeon=true},--The Cauldron
    ]]
}
if isPTSAPIVersionLive == true then
    for _, mappingData in ipairs(mappingForSetItemCollectionsNotYetLive) do
        tins(lib.setDataPreloaded[LIBSETS_TABLEKEY_SET_ITEM_COLLECTIONS_ZONE_MAPPING], mappingData)
    end
end