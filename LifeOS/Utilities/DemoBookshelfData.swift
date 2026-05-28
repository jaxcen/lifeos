import SwiftUI

/// 演示书架数据
struct DemoBookshelfData {

    static let books: [DiaryBook] = [
        calmBook,
        fogBook,
        growthBook
    ]

    // MARK: - 静水深流

    private static var calmBook: DiaryBook {
        DiaryBook(
            title: "静水深流",
            subtitle: "平静的日子",
            coverColor: .moodCalm,
            coverIcon: "leaf.fill",
            chapters: [
                BookChapter(
                    title: "安静的一天",
                    date: date(2026, 3, 5),
                    body: "今天没有发生什么特别的事。早上按惯例喝了杯咖啡，坐在窗边看了一会儿楼下的行人。每个人都在赶路，只有我像是被时间遗忘了一样。但这种遗忘，感觉并不坏。下午读了三十页书，是关于一个天文学家的故事。他说宇宙中最安静的地方，反而蕴含着最大的能量。我想，人的内心大概也是这样。",
                    insight: "安静不是空虚，而是一种蓄力的状态",
                    observerNote: "他今天像是湖面，看似平静，实则深处有暗流在涌动",
                    detectedMood: "平静",
                    goalPrediction: "正在学习与自己独处，这是一种珍贵的能力"
                ),
                BookChapter(
                    title: "雨天的窗边",
                    date: date(2026, 3, 12),
                    body: "下雨了。不是那种暴烈的雨，是春天特有的绵绵细雨。我把椅子搬到阳台上，听着雨声发呆。雨水顺着玻璃流下来，把对面的楼都模糊成了一团颜色。突然想到小时候也喜欢这样看雨，那时候觉得世界很大，现在觉得世界刚刚好。给妈妈打了个电话，她问我吃了没，我说吃了。就这么简单。",
                    insight: "简单的连接，是心灵最好的养分",
                    observerNote: "他在雨声中找到了某种久违的安宁，像回到了小时候",
                    detectedMood: "平静",
                    goalPrediction: "开始懂得珍惜日常中的微小幸福"
                ),
                BookChapter(
                    title: "深夜的独白",
                    date: date(2026, 3, 28),
                    body: "凌晨一点了，还是睡不着。不是焦虑，就是不困。索性起来写点什么。这个月过得很快，回头看好像什么都没做，但又好像什么都做了一点。工作上没什么突破，但也没有出错。生活上没什么惊喜，但也没有失望。也许这就是所谓的「稳」吧。不是每个阶段都需要飞跃，有时候站稳本身就是一种进步。",
                    insight: "不追求飞跃的时刻，恰恰是扎根最深的时刻",
                    observerNote: "他终于不再用「做了多少」来衡量自己，而是学会了用「稳住了」来肯定自己",
                    detectedMood: "平静",
                    goalPrediction: "正在建立一种更可持续的自我评价体系"
                )
            ],
            isDemo: true
        )
    }

    // MARK: - 穿过迷雾

    private static var fogBook: DiaryBook {
        DiaryBook(
            title: "穿过迷雾",
            subtitle: "不确定的日子",
            coverColor: .moodReflective,
            coverIcon: "cloud.fog.fill",
            chapters: [
                BookChapter(
                    title: "不安的早晨",
                    date: date(2026, 4, 3),
                    body: "醒来的时候心跳就很快。今天要去做一个重要的决定，关于是否换工作。旧的工作虽然无聊但稳定，新的机会看起来很好但充满未知。吃早餐的时候手有点抖，不是因为咖啡。出门前对着镜子深呼吸了三次。不管结果如何，至少我还在往前走。",
                    insight: "恐惧是行动的前奏，不是停止的信号",
                    observerNote: "他站在十字路口，虽然双腿发抖，但目光是朝前的",
                    detectedMood: "焦虑",
                    goalPrediction: "正在练习带着恐惧前进，而不是等恐惧消失"
                ),
                BookChapter(
                    title: "选择的重量",
                    date: date(2026, 4, 10),
                    body: "做了决定。选了新的那条路。签完字的那一刻，手是抖的。回来的路上一直在想「如果选错了怎么办」。但是转念一想，哪有什么对错呢？每条路都有风景，也都有坑。重要的是走路的人，不是路本身。晚上给自己煮了碗面，加了个蛋。算是庆祝吧。",
                    insight: "选择的意义不在于对错，在于你愿意为它负责",
                    observerNote: "他做出了选择，虽然不确定，但姿态是坚定的",
                    detectedMood: "焦虑",
                    goalPrediction: "正在学习接受不确定性，把它当作生活的一部分"
                ),
                BookChapter(
                    title: "迷雾中的一步",
                    date: date(2026, 4, 18),
                    body: "新工作的第一周。什么都不懂，什么都要问。感觉自己像个傻子。但是同事们都很好，没有人因为我问笨问题而不耐烦。中午和一个前辈吃饭，他说「每个人都是从不懂开始的，重要的不是你现在会什么，而是你愿意学什么」。这句话让我下午的工作轻松了很多。迷雾还在，但我好像看到了一点光。",
                    insight: "迷雾不是终点，只是路上的一种天气",
                    observerNote: "他在迷雾中迈出了第一步，虽然看不清前方，但脚下是实的",
                    detectedMood: "迷茫",
                    goalPrediction: "正在适应新的环境，每一次提问都是一次成长"
                )
            ],
            isDemo: true
        )
    }

    // MARK: - 向上生长

    private static var growthBook: DiaryBook {
        DiaryBook(
            title: "向上生长",
            subtitle: "突破的日子",
            coverColor: .moodHappy,
            coverIcon: "arrow.up.circle.fill",
            chapters: [
                BookChapter(
                    title: "第一次坚持",
                    date: date(2026, 5, 1),
                    body: "跑步坚持了一整周。七天，每天三公里。听起来不多，但对我来说已经是奇迹了。以前每次都是三天打鱼两天晒网，这次不知道为什么就坚持下来了。可能是跑步的时候什么都不想，只听自己的呼吸声，那种感觉很舒服。今天跑完的时候，夕阳正好打在脸上，暖暖的。觉得自己好像真的在变好。",
                    insight: "坚持不是意志力的胜利，而是找到了让你舒服的方式",
                    observerNote: "他第一次体验到了「坚持」的甜头，不是痛苦的忍耐，而是愉悦的重复",
                    detectedMood: "成长",
                    goalPrediction: "正在建立一个可以持续的好习惯"
                ),
                BookChapter(
                    title: "突破舒适区",
                    date: date(2026, 5, 15),
                    body: "今天在公司做了一次公开演讲。以前最怕的就是在人前说话，每次都会紧张到声音发抖。这次准备了很久，上台前还是紧张。但开口之后，发现大家都在认真听，没有人嘲笑我。讲完之后，有三个人来跟我说「讲得很好」。我知道可能只是客气，但还是很开心。原来恐惧这个东西，你面对它，它就变小了。",
                    insight: "恐惧是一个守门员，不是一堵墙",
                    observerNote: "他站在了自己最害怕的地方，然后发现那里并没有想象中那么可怕",
                    detectedMood: "突破",
                    goalPrediction: "正在打破自己给自己设的限制"
                ),
                BookChapter(
                    title: "回头看的勇气",
                    date: date(2026, 5, 25),
                    body: "翻到了三个月前写的日记。那时候的自己，焦虑、迷茫、不确定。现在的自己，好像也没好到哪里去，但至少知道了一件事：我能撑过来。那时候觉得天要塌了，现在回头看，不过是路上的一个小坎。也许三个月后回头看今天，也会觉得不过如此。但此刻的我，确实为自己骄傲。",
                    insight: "回头看不是为了停留，而是为了确认自己走了多远",
                    observerNote: "他回头看了一眼，不是为了留恋，而是为了给自己鼓掌",
                    detectedMood: "成长",
                    goalPrediction: "正在学会用过去的自己来肯定现在的自己"
                )
            ],
            isDemo: true
        )
    }

    // MARK: - Date Helper

    private static func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        Calendar.current.date(from: DateComponents(year: year, month: month, day: day)) ?? Date()
    }
}
