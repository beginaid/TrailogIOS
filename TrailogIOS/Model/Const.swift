import UIKit
import Foundation

struct Const {
    static let year = Calendar.current.component(.year, from: Date())
    static let errorFormsNotFilled = "必要項目を入力して下さい"
    static let errorPasswordNotMatched = "パスワードが一致しません"
    static let errorEmailInvalid = "正しいメールアドレスを\n入力してください"
    static let errorEmailAlreadyInUse = "このメールアドレスは\nすでに使われています"
    static let errorPasswordTooShort = "パスワードは6文字以上で\n入力してください"
    static let errorDefault = "エラーが起きました\nしばらくしてから再度お試しください"
    static let errorWeightNotFilled = "体重を入力して下さい"
    
    static let successAddWeight = "体重編集完了"
    static let successDeleteWeight = "体重削除完了"
    
    static let identifierMain = "Main"
    static let identifierLogin = "Login"
    
    static let colorAccent = "AccentColor"
    static let colorBlack = "Black"
    static let rgbLightBlack = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
    
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
