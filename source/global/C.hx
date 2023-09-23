package global;
import haxe.Log;
import haxe.Utf8;
import help.DialogueManager;
import openfl.Assets;
import flash.display.BitmapData;

/**
 * global constants etc
 * @author Melos Han-Tani
 */

class C 
{

	
	public static var font_apple_white:BitmapData;
	public static var font_aliph_script_white:BitmapData;
	public static var font_aliph_script_white_small:BitmapData;
	public static var font_other_white:BitmapData;
	public static var font_other_white_small:BitmapData;
	public static var font_jp:BitmapData; // Holds the ref to bitmap font file
	public static var font_zh_simp:BitmapData;
	public static inline var TS:Int = 16;
	
	public static var CURRENT_FONT_TYPE:String = "apple_white";
	
	public static inline var C_FONT_APPLE_WHITE_STRING:String = "abcdefghijklmnopqrstuvwxyz_ABCDEFGHIJKLMNOPQRSTUVWXYZ\'1234567890.:,;\'\"(!?)+-*/=$]";
	public static inline var APPLE_FONT_w:Int = 7;
	public static inline var APPLE_FONT_h:Int = 8;
	public static inline var APPLE_FONT_cpl:Int = 27;
	
	public static inline var C_FONT_ALIPH_STRING:String = " !\"#$%&'()*+,-./0123456789:;<=>? ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~’‘ @ あいうえお■●▲✖";
	public static inline var ALIPH_FONT_w:Int = 7;
	public static inline var ALIPH_FONT_h:Int = 10;
	public static inline var ALIPH_FONT_cpl:Int = 10;
	
	
	public static inline var C_FONT_ALIPH_SMALL_STRING:String = "_               0123456789       ABCDEFGHIJKLMNOPQRSTUVWXYZ      abcdefghijklmnopqrstuvwxyz.        あいうえお　　　　　";
	public static inline var ALIPH_FONT_SMALL_w:Int = 6;
	public static inline var ALIPH_FONT_SMALL_h:Int = 9;
	public static inline var ALIPH_FONT_SMALL_cpl:Int = 10;	
	
	
	public static inline var C_FONT_OTHER_STRING:String = " !\"#$%&'()*+,-./0123456789:;<=>? ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~’‘ @ あいうえお■●▲✖ ~ÄÖÜäöüß¡-¿ÁÉxÍÑÓÚáéíñóúАБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯабвгдеёжзийклмнопрстуфхцчшщъыьэюя";
	public static inline var OTHER_FONT_w:Int = 7;
	public static inline var OTHER_FONT_h:Int = 12;
	public static inline var OTHER_FONT_cpl:Int = 10;
	
	public static inline var C_FONT_OTHER_SMALL_STRING:String = "      0123456789       ABCDEFGHIJKLMNOPQRSTUVWXYZ      abcdefghijklmnopqrstuvwxyz.-       あいうえお　　　　　ÄÖÜäöüßÁÉxÍÑÓÚáéíñóúАБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯабвгдеёжзийклмнопрстуфхцчшщъыьэюя    ";
	public static inline var OTHER_SMALL_FONT_w:Int = 6;
	public static inline var OTHER_SMALL_FONT_h:Int = 12;
	public static inline var OTHER_SMALL_FONT_cpl:Int = 10;
	
	
	
	
	//public static inline var ZH_SIMP_FONT_w:Int = 16;
	//public static inline var ZH_SIMP_FONT_h:Int = 18;
	public static inline var ZH_SIMP_FONT_w:Int = 13;
	public static inline var ZH_SIMP_FONT_h:Int = 14;
	public static inline var ZH_SIMP_FONT_cpl:Int = 60;
	// don't forget to remove the '\' here!!
	public static var C_FONT_ZH_SIMP_STRING:String = "!\"$%&' ()*+,-./0123456789:=>?ABCDEFGHIJKLMNOPQRSTUVWXYZ[]^_ abcdefghijklmnopqrstuvwxyz{}·—‘’“”…■●✖、。《》【】あいうえお一丁七万丈三上下不与丐丑专且世丘业丛东丝丢两严个中丰临丹为主丽举乃久么义之乌乍乎乏乐乘乞也习乡书买乱了予争事二于亏云互五亚些亡交产享京亮亲人什仁仅仆仇今介仍从仓仔他仗付仙代令以们仰件价任份仿企伊伍伐休众优伙会伞伟传伤伦伪伯伴伸似但位低住体何余佛作你佩佳使例供依侦侧侵便促俗保信俩修俱倍倒倘候借倦倪值倾假偏做停健偶偷偿储傲傻像僻儿允充兆先光克免兔入全八公六兰共关兴其具典养兽内册再冒写农冬冰冲决况冷冻冽净准凉凌减几凯凹出击刀分切划列则刚创初删判利别到制刷刺刻剂前剧剩剪副力办功加务劣动助努劫励劲劳势勃勇勒募勾包匆化北匙匠区医匿十千升午半华协卑单卖南博卜占卡卧卫印危即却卵卷厅历厉压厌厕厚原厦厨去参又及友双反发叔取受变叙叛口古句另叨只叫召可台史右叶号司叹吃各合吉吊同名后吐向吓吗君否吧含听启吱吵吸吹吼呀呃呆呈告呐员呢周味呵呼命和咒咔咖咝咦咬咯咳咽哀品哄哇哈响哎哒哟哥哦哪哭哲哼哽唉唔唠唤售唯唱唷商啊啜啡啥啦啧啸喂善喊喔喜喝喧喷嗅嗞嗨嗯嘎嘘嘛嘟嘲嘴嘻嘿噜噢器噱嚏嚓嚣囊四回因团园困围固国图圈土圣在地场圾址均坏坐块坚坠坡坦垂垃型埃埋城域基堂堆堵塌塔塞填境墓墙增墟壁壤士壮声处备复夏外多夜够大天太夫央失头夸夹奇奋奏奔奖套奢奥女奶她好如妈妒妙妥妹姆始姐姑姨姿威娃娇娘婪婴媒媲嫂嫉子孔字存孢季孤学孩宁它宅宇守安完宏宗官宙定宜宝实审客宣室宫害家容宽寂寄密富寒寓寞察寸对寺寻导封射将尉尊小少尔尖尘尝尤尬就尴尸尼尽尾局屁层居屈屋屏展属山屿岁岖岗岛岩岸峡峭峰崎崖崩川巡工左巧巨巩差己已巴巾币市布师希帐帕带席帮常幕幢干平年并幸幺幻幽广庄床序庐库应底店庙府庞废度座庭康廉廊延廷建开异弃弄式引弗张弥弱弹强归当录形影彼往征径待很律徒得御循微德心必忆忍志忘忙忡忧快念忽怀态怎怒怕怖怜思急性怨怪总恋恐恒恢恨恩恭息恰恶恼悉悚悟悠患悦您悬悲情惊惑惜惠惧惩惫惯想惹愉意愚感愤愧愿慈慌慎慢慧慨慰慷憧憬憾懂懒戈戏成我或战戳戴户房所扇手才扎打扔托扛执扩扫扭扮扯扰批找承技把抓投抖抗折抛护报抱抵抹抽拂担拇拉拍拓拙招拜拥拦择括拯拳拼拽拾拿持挂指按挑挖挡挣挤挥振挺捎捐捕损换捣据捷掉掌排掘探接控推措掷描提插握揣援揽搁搜搞搬搭携搽摄摆摇摔摘摸撒撞撤播撼操擎擦攀支收改攻放政故效敌敏救教敢散敬数敲整文斗料斜斥断斯新方施旁旅旋族无既日旦旧旨早旱时旺昂昆明昏易昔星映春昨是昻显晃晋晓晕晚晤晨普景晶智暂暖暗暴曲更曾替最月有朋服朗望朝期木未末本术朱朴朵机杀杂权杆李材村杜束条来杯杰松板极构析枕林枚果枝枢枪架柄某染柜查柱柳柴标栏树栖栗校样核根格桂桃框案桌档桥桶梁梅梦梭梯械检棒棕棘棚森棱棵椅植椎楚楼概榜槽模橙橡次欢欣欲欸欺款歇歉歌止正此步武歧歹死殃殊残殖段毁母每毒比毕毙毛毫毯民氓气氛水永求汇汉汗池污汤汪汽沃沉沙沟没河油治沼沾沿泄泉泊法泛泡波泣泥注泳泵泽洁洋洛洞洪活洼派流浅测济浏浓浪浮浴海消涝润涨液淇淋淌淡深淳混淹添清渐渔渡温渴游湖湛湿溃溉源溜溶滋滑滚满滥滩漂漏演漠漫潜潦潭潺激瀑灌火灭灯灰灵灾炎炒炖炫炮炸点炼烂烈烘烛烟烤烦烧热焦然煎照煮熊熟燃燕燥爆爬爱父爸爽片版牌牙牛牢牧物牲牵特犯状犹狂狩独狱狸猎猜猝猪献玄率玉王玛玩环现玻珊珍珞珠班球理琳瑚璃瓦瓶甘甚甜生用田由甲电男画界畏留畜略番疏疑疗疚疯疲疼病症痘痛登白百的皆皑皮盆益盐监盒盔盘盛目盯直相盹盾省眉看真眠眼着睁睐睛睡督睹瞄瞧瞬知矩短石矿码研破砸础硬确碌碍碎碑碗碟碰磁磅磨示礼社祈祖祝神票祷祸禁福离秀私秋种科秘租积称移稀程稍税稳稻稼稽稿穴究空穿突窄窒窗窟立站竞竟童端笑笔笛符笨第笼等筑筒答筹签简算管箱篇篮篷籍米类粉粒粗粘粥粱粹精糊糕糖糟系素索紧紫累絮繁纠红约级纪纯纱纳纵纷纸纽线练组细织终绍经绑绒结绕绘给络绝统继绪续维绿缀缆缓编缘缝缠缩缸缺罐网罗罚罢罪置美群羹翅翠翡翻翼耀老考者而耐耕耗耳耶耸耽聆聊聋职联聘聚聪肃肉股肢肤肥肩肮肯胁胃背胜胞胡胶胸能脉脊脏脑脖脚脱脸脾腌腐膀臂自臭至致舒舞航般舶船艘良艰色艺艾节芒芙芦花苍苔苗若苦英苹范茅茫茬茴茸草荐荒荚荟荡荣药荷莅莎莓莫莱获莽菇菊菌菜萝营落著葬葱蒂蓝蓬蔬蕨蕾薄薏藏藓蘑虐虑虔虫虽蚀蛋蛮蛾蜂蜒蜡蜿蝇融螺蠕蠢血行衍街衡衣补表衰衷袋被袭裂装裙裹西要见观规视览觉角解触言誓警计订认讨让训议讯记讲讶许论设访证评诅识诉诊词译试诗诚话诡询该详诩语误说请诸诺读课谁调谅谈谋谐谓谜谢谣谨谬谱谴谷豆象豪豫贝负贡财责败货质贪贫购贴贵贷贸费贼资赌赏赖赚赛赞走赴赶起超越趋趟趣足趾跃跌跑跚距跟跨路跳践踏踢踩踪蹊蹒躁身躯车转轮轻载较辅辈辉输辛辜辞辟辣辨边辽达迁迄迅过迈迎运近返还这进远连迟迪迭述迷迹追退送适逃逆选透递途逗通逝速造逢逸逻逼逾遇遍道遗遥遭遵避邀那邦邪邮郁郊部都配酪酬酱酷酸酿醒采释里重野量金鉴针钉钓钟钥钦钮钱钳钻铭铲银链销锁锅锋锐错锤键镇镜长门闪闭问闲间闷闹闻阅阔队阱防阳阴阵阶阻阿附际陆陈陌降限陡院除险陪陵陶陷随隐隔隙障隧难雄雅集雏雕雨雪零雷雾需震霍霜霞青静非靠面革鞋韦音页顶项顺须顽顾顿颂预领颇频颗题颜额颤风飕飘飞食餐饭饮饰饱饼饿馆首香马驰驱驶驾骄验骑骗骚骤骨骰骸高髦鬼魂魔鱼鲁鲍鲑鲜鲸鸟鸡鸽鹅麦麻黄黏黑默鼓鼠鼹鼾齐龄龙龛！（），：；？扶抬撇胆<";
	
	// Set in init_jp()
	public static var C_FONT_JP_STRING:String = " !\"#$%&'()*+,-./0123456789:;<=>?ABCDEFGHIJKLMNOPQRSTU　VWXYZ[]^_`abcdefghijklmnopqrstuvwxyz{|}~@’‘\\ぁあぃいぅうぇえぉおかがきぎくぐけげこごさざしじすずせぜそぞただちぢっつづてでとどなにぬねのはばぱひびぴふぶぷへべぺほぼぽまみむめもゃやゅゆょよらりるれろゎわをんァアィイゥウェエォオカガキギクグケゲコゴサザシジスズセゼソゾタダチヂッツヅテデトドナニヌネノハバパヒビピフブプヘベペホボポマミムメモャヤュユョヨラリルレロヮワヲンヴヵヶ・ー日一国会人年大十二本中長出三同時政事自行社見月分議後前民生連五発間対上部東者党地合市業内相方四定今回新場金員九入選立開手米力学問高代明実円関決子動京全目表戦経通外最言氏現理調体化田当八六約主題下首意法不来作性的要用制治度務強気小七成期公持野協取都和統以機平総加山思家話世受区領多県続進正安設保改数記院女初北午指権心界支第産結百派点教報済書府活原先共得解名交資予川向際査勝面委告軍文反元重近千考判認画海参売利組知案道信策集在件団別物側任引使求所次水半品昨論計死官増係感特情投示変打男基私各始島直両朝革価式確村提運終挙果西勢減台広容必応演電歳住争談能無再位置企真流格有疑口過局少放税検藤町常校料沢裁状工建語球営空職証土与急止送援供可役構木割聞身費付施切由説転食比難防補車優夫研収断井何南石足違消境神番規術護展態導鮮備宅害配副算視条幹独警宮究育席輸訪楽起万着乗店述残想線率病農州武声質念待試族象銀域助労例衛然早張映限親額監環験追審商葉義伝働形景落欧担好退準賞訴辺造英被株頭技低毎医復仕去姿味負閣韓渡失移差衆個門写評課末守若脳極種美岡影命含福蔵量望松非撃佐核観察整段横融型白深字答夜製票況音申様財港識注呼渉達良響阪帰針専推谷古候史天階程満敗管値歌買突兵接請器士光討路悪科攻崎督授催細効図週積丸他及湾録処省旧室憲太橋歩離岸客風紙激否周師摘材登系批郎母易健黒火戸速存花春飛殺央券赤号単盟座青破編捜竹除完降超責並療従右修捕隊危採織森競拡故館振給屋介読弁根色友苦就迎走販園具左異歴辞将秋因献厳馬愛幅休維富浜父遺彼般未塁貿講邦舞林装諸夏素亡劇河遣航抗冷模雄適婦鉄寄益込顔緊類児余禁印逆王返標換久短油妻暴輪占宣背昭廃植熱宿薬伊江清習険頼僚覚吉盛船倍均億途圧芸許皇臨踏駅署抜壊債便伸留罪停興爆陸玉源儀波創障継筋狙帯延羽努固闘精則葬乱避普散司康測豊洋静善逮婚厚喜齢囲卒迫略承浮惑崩順紀聴脱旅絶級幸岩練押軽倒了庁博城患締等救執層版老令角絡損房募曲撤裏払削密庭徒措仏績築貨志混載昇池陣我勤為血遅抑幕居染温雑招奈季困星傷永択秀著徴誌庫弾償刊像功拠香欠更秘拒刑坂刻底賛塚致抱繰服犯尾描布恐寺鈴盤息宇項喪伴遠養懸戻街巨震願絵希越契掲躍棄欲痛触邸依籍汚縮還枚属笑互複慮郵束仲栄札枠似夕恵板列露沖探逃借緩節需骨射傾届曜遊迷夢巻購揮君燃充雨閉緒跡包駐貢鹿弱却端賃折紹獲郡併草徹飲貴埼衝焦奪雇災浦暮替析預焼簡譲称肉納樹挑章臓律誘紛貸至宗促慎控贈智握照宙酒俊銭薄堂渋群銃悲秒操携奥診詰託晴撮誕侵括掛謝双孝刺到駆寝透津壁稲仮暗裂敏鳥純是飯排裕堅訳盗芝綱吸典賀扱顧弘看訟戒祉誉歓勉奏勧騒翌陽閥甲快縄片郷敬揺免既薦隣悩華泉御範隠冬徳皮哲漁杉里釈己荒貯硬妥威豪熊歯滞微隆埋症暫忠倉昼茶彦肝柱喚沿妙唱祭袋阿索誠忘襲雪筆吹訓懇浴俳童宝柄驚麻封胸娘砂李塩浩誤剤瀬趣陥斎貫仙慰賢序弟旬腕兼聖旨即洗柳舎偽較覇兆床畑慣詳毛緑尊抵脅祝礼窓柔茂犠旗距雅飾網竜詩昔繁殿濃翼牛茨潟敵魅嫌魚斉液貧敷擁衣肩圏零酸兄罰怒滅泳礎腐祖幼脚菱荷潮梅泊尽杯僕桜滑孤黄煕炎賠句寿鋼頑甘臣鎖彩摩浅励掃雲掘縦輝蓄軸巡疲稼瞬捨皆砲軟噴沈誇祥牲秩帝宏唆鳴阻泰賄撲凍堀腹菊絞乳煙縁唯膨矢耐恋塾漏紅慶猛芳懲郊剣腰炭踊幌彰棋丁冊恒眠揚冒之勇曽械倫陳憶怖犬菜耳潜珍梨仁克岳概拘墓黙須偏雰卵遇湖諮狭喫卓干頂虫刷亀糧梶湯箱簿炉牧殊殖艦溶輩穴奇慢鶴謀暖昌拍朗丈鉱寛覆胞泣涙隔浄匹没暇肺孫貞靖鑑飼陰銘鋭随烈尋渕稿枝丹啓也丘棟壌漫玄粘悟舗妊塗熟軒旭恩毒騰往豆遂晩狂叫栃岐陛緯培衰艇屈径淡抽披廷錦准暑拝磯奨妹浸剰胆氷繊駒乾虚棒寒孜霊帳悔諭祈惨虐翻墜沼据肥徐糖搭姉髪忙盾脈滝拾軌俵妨盧粉擦鯨漢糸荘諾雷漂懐勘綿栽才拐笠駄添汗冠斜銅鏡聡浪亜覧詐壇勲魔酬紫湿曙紋卸奮趙欄逸涯拓眼瓶獄筑尚阜彫咲穏顕巧矛垣召欺釣缶萩粧隻葛脂粛栗愚蒸嘉遭架篠鬼庶肌稚靴菅滋幻煮姫誓耕把践呈疎仰鈍恥剛疾征砕謡嫁謙后嘆俣菌鎌巣泥頻琴班淵棚潔酷宰廊寂辰隅偶霞伏灯柏辛磨碁俗漠邪晶辻麦墨鎮洞履劣那殴娠奉憂朴亭姓淳荻筒鼻嶋怪粒詞鳩柴偉酔惜穫佳潤悼乏胃該赴桑桂髄虎盆晋穂壮堤飢傍疫累痴搬畳晃癒桐寸郭机尿凶吐宴鷹賓虜膚陶鐘憾畿猪紘磁弥昆粗訂芽尻庄傘敦騎寧濯循忍磐猫怠如寮祐鵬塔沸鉛珠凝苗獣哀跳灰匠菓垂蛇澄縫僧幾眺唐亘呉凡憩鄭芦龍媛溝恭刈睡錯伯帽笹穀柿陵霧魂枯弊釧妃舶餓腎窮掌麗綾臭釜悦刃縛暦宜盲粋辱毅轄猿弦嶌稔窒炊洪摂飽函冗涼桃狩舟貝朱渦紳枢碑鍛刀鼓裸鴨符猶塊旋弓幣膜扇脇腸憎槽鍋慈皿肯樋楊伐駿漬燥糾亮墳坪畜紺慌娯吾椿舌羅坊峡俸厘峰圭醸蓮弔乙倶汁尼遍堺衡呆薫瓦猟羊窪款閲雀偵喝敢畠胎酵憤豚遮扉硫赦挫挟窃泡瑞又慨紡恨肪扶戯伍忌濁奔斗蘭蒲迅肖鉢朽殻享秦茅藩沙輔曇媒鶏禅嘱胴粕冨迭挿湘嵐椎灘堰獅姜絹陪剖譜郁悠淑帆暁鷲傑楠笛芥其玲奴誰錠拳翔遷拙侍尺峠篤肇渇榎俺劉幡諏叔雌亨堪叙酢吟逓痕嶺袖甚喬崔妖琵琶聯蘇闇崇漆岬癖愉寅捉礁乃洲屯樽樺槙薩姻巌淀麹賭擬塀唇睦閑胡幽峻曹哨詠炒屏卑侮鋳抹尉槻隷禍蝶酪茎汎頃帥梁逝滴汽謎琢箕匿爪芭逗苫鍵襟蛍楢蕉兜寡琉痢庸朋坑姑烏藍僑賊搾奄臼畔遼唄孔橘漱呂桧拷宋嬢苑巽杜渓翁藝廉牙謹瞳湧欣窯褒醜魏篇升此峯殉煩巴禎枕劾菩堕丼租檜稜牟桟榊錫荏惧倭婿慕廟銚斐罷矯某囚魁薮虹鴻泌於赳漸逢凧鵜庵膳蚊葵厄藻萬禄孟鴈狼嫡呪斬尖翫嶽尭怨卿串已嚇巳凸暢腫粟燕韻綴埴霜餅魯硝牡箸勅芹杏迦棺儒鳳馨斑蔭焉慧祇摯愁鷺楼彬袴匡眉苅讃尹欽薪湛堆狐褐鴎瀋挺賜嵯雁佃綜繕狛壷橿栓翠鮎芯蜜播榛凹艶帖伺桶惣股匂鞍蔦玩萱梯雫絆錬湊蜂隼舵渚珂煥衷逐斥稀癌峨嘘旛篭芙詔皐雛娼篆鮫椅惟牌宕喧佑蒋樟耀黛叱櫛渥挨憧濡槍宵襄妄惇蛋脩笘宍甫酌蚕壕嬉囃蒼餌簗峙粥舘銕鄒蜷暉捧頒只肢箏檀鵠凱彗謄諌樫噂脊牝梓洛醍砦丑笏蕨噺抒嗣隈叶凄汐絢叩嫉朔蔡膝鍾仇伽夷恣瞑畝抄杭寓麺戴爽裾黎惰坐鍼蛮塙冴旺葦礒咸萌饗歪冥偲壱瑠韮漕杵薔膠允眞蒙蕃呑侯碓茗麓瀕蒔鯉竪弧稽瘤澤溥遥蹴或訃矩厦冤剥舜侠贅杖蓋畏喉汪猷瑛搜曼附彪撚噛卯桝撫喋但溢闊藏浙彭淘剃揃綺徘巷竿蟹芋袁舩拭茜凌頬厨犀簑皓甦洸毬檄姚蛭婆叢椙轟贋洒貰儲緋貼諜鯛蓼甕喘怜溜邑鉾倣碧燈諦煎瓜緻哺槌啄穣嗜偕罵酉蹄頚胚牢糞悌吊楕鮭乞倹嗅詫鱒蔑轍醤惚廣藁柚舛縞謳杞鱗繭釘弛狸壬硯、。「」：々捗填［］（）";
	public static inline var JP_FONT_w:Int = 12;
	public static inline var JP_FONT_h:Int = 13;
	public static inline var JP_FONT_cpl:Int = 54;
	
	public static inline var FONT_TYPE_ALIPH_SMALL_WHITE:String = "aliph_font_white_small";
	public static inline var FONT_TYPE_ALIPH_WHITE:String = "aliph_font_white";
	public static inline var FONT_TYPE_APPLE_WHITE:String = "apple_white";
	public static inline var FONT_TYPE_EDITOR:String = "editorwhite";
	
	public static inline var MAX_TILESET_SIZE:Int = 1000;
	public static var NR_WORD_ARRAY:Array<String>;
	public static inline var ALPHABET:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
	
	public static var GAME_WIDTH:Int = 416;
	public static var GAME_HEIGHT:Int = 256;
	public static var num_langs:Int = 5; // en , zh-simpfor, de , ru, es now
	/**
	 * Extension to the csv directory, relative to the game binary (export/windows/cpp/bin/)
	 * being run through FlashDevelop
	 */
	public static var EXT_NONCRYPTASSETS:String = "../../../../_noncrypt_assets/";
	public static var EXT_ASSETS:String = "../../../../assets/";
	public static var EXT_CSV:String = "../../../../assets/csv/";
	public static var EXT_DEV:String = "../../../../";
	public static var EXT_MAP_ENT:String = "../../../../assets/map_ent/";
	public static var EXT_TILESET:String = "../../../../assets/tileset/";
	public static var EXT_TILE_META:String = "../../../../assets/tile_meta/";
	public static var EXT_MAPPINGS:String = "../../../../assets/";
	public static var EXT_MP3:String = "../../../../assets/mp3/";
	public static var EXT_SFX:String = "../../../../assets/mp3/sfx/";
	
	// Full energize messages
	public static inline var MSGTYPE_ENERGIZE:String = "energize";
	public static inline var MSGTYPE_MOVED_BY_EDITOR:String = "mov";
	public static inline var MSGTYPE_DEENERGIZE:String = "deenergize";
	public static inline var MSGTYPE_ENERGIZE_DARK:String = "energize_d";
	public static inline var MSGTYPE_ENERGIZE_LIGHT:String = "energize_l";
	
	/** Need to append number to end **/
	public static inline var MSGTYPE_ENERGIZE_AMT_D:String = "energ_amt_d";
	public static inline var MSGTYPE_ENERGIZE_AMT_L:String = "energ_amt_l";
	// One point
	public static inline var MSGTYPE_ENERGIZE_TICK_DARK:String = "energize_tick_d";
	public static inline var MSGTYPE_ENERGIZE_TICK_LIGHT:String = "energize_tick_l";
	//etc
	public static inline var MSGTYPE_STOP:String = "stooop";
	public static inline var MSGTYPE_SIGNAL:String = "signal";
	
	public static inline var RECV_STATUS_OK:Int = 0;
	public static inline var RECV_STATUS_NOGOOD:Int = 1;
	
	public function new() 
	{
		
	}
	
	public static function init_jp():Void {
		//C.C_FONT_JP_STRING = Assets.getText("assets/dialogue/jpstr.txt");
		//Log.trace(Utf8.sub(C.C_FONT_JP_STRING, 0, 200));
		//DialogueManager.CUR_LANGTYPE = DialogueManager.LANGTYPE_JP;
	}
	
	public static var jp_a:String = "あ";
	
	public static var did_init:Bool = false;
	public static function init():Void {
		
		//var s:String = "ありがとう";
		//for (i in 0...Utf8.length(s)) {
			//Log.trace(Utf8.charCodeAt(s, i));
		//}
		//Log.trace(Utf8.charCodeAt("ありがとう", 0));
		//Log.trace(Utf8.charCodeAt("ありがとう", 1));
		//Log.trace(Utf8.charCodeAt("ありがとう", 2));
		//Log.trace(Utf8.charCodeAt("ありがとう", 3));
		//Log.trace(Utf8.charCodeAt("ありがとう", 4));
//
		#if mac
		Log.trace("update mac");
		var three_up:String = "../../../";

		EXT_ASSETS = "../../../"+EXT_ASSETS;
		EXT_MAPPINGS = "../../../"+EXT_MAPPINGS;
		EXT_NONCRYPTASSETS = three_up+EXT_NONCRYPTASSETS;
		EXT_CSV = three_up + EXT_CSV;
		EXT_DEV = three_up + EXT_DEV;
		EXT_MAP_ENT = three_up + EXT_MAP_ENT;
		EXT_TILESET = three_up + EXT_TILESET;
		EXT_TILE_META = three_up + EXT_TILE_META;
		EXT_MP3 = three_up + EXT_MP3;
		EXT_SFX = three_up + EXT_SFX;

		#end
		
			
		if (did_init) return;
		NR_WORD_ARRAY = ["ONE", "TWO", "THREE", "FOUR", "FIVE", "SIX", "SEVEN", "EIGHT", "NINE", "ZERO"];
		font_jp = Assets.getBitmapData("assets/sprites/font/jp_white.png");
		//font_zh_simp = Assets.getBitmapData("assets/sprites/font/zh_simp.png");
		font_zh_simp = Assets.getBitmapData("assets/sprites/font/zh_simp10.png");
		font_apple_white = Assets.getBitmapData("assets/sprites/font/font-white-apple-7x8.png");
		//font_aliph_script_white = Assets.getBitmapData("assets/sprites/font/aliph_script.png");
		font_aliph_script_white = Assets.getBitmapData("assets/sprites/font/aliph_script2_white.png");
		font_aliph_script_white_small = Assets.getBitmapData("assets/sprites/font/aliph_script2_small_white.png");
		
		font_other_white = Assets.getBitmapData("assets/sprites/font/other_white.png");
		font_other_white_small = Assets.getBitmapData("assets/sprites/font/other_small_white.png");
		did_init = true;
		
	}
	
}