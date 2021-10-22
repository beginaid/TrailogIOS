import Foundation

struct Const {
    static let errorFormsNotFilled = "必要項目を入力して下さい"
    static let errorPasswordNotMatched = "パスワードが一致しません"
    static let errorEmailInvalid = "正しいメールアドレスを\n入力してください"
    static let errorEmailAlreadyInUse = "このメールアドレスは\nすでに使われています"
    static let errorPasswordTooShort = "パスワードは6文字以上で\n入力してください"
    static let errorDefault = "エラーが起きました\nしばらくしてから再度お試しください"
    
    static let identifierMain = "Main"

    static let dropListTraining = [
        "ベンチプレス",
        "スミスマシン",
        "ダンベルフライ",
        "チェストプレス",
        "リアレイズ",
        "ショルダープレス",
        "フロントレイズ",
        "サイドレイズ",
        "アームカール",
        "プリチャーカール",
        "トライセプスEXT(マシン)",
        "トライセプスEXT(ダンベル)",
        "クランチ",
        "アブドミナルクランチ",
        "アブローラー",
        "ウィンドミル",
        "レッグカール",
        "レッグプレス",
        "ヒップアダクション",
        "ヒップアブダクション"
    ]

    static let dropListWorkout = [
        "ラン",
        "バイク",
        "スイム"
    ]
}
