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
    static let successAddTraining = "筋トレ編集完了"
    static let successAddWorkout = "有酸素編集完了"
    static let successDelete = "削除完了"
    
    static let addWeightEN = "weight"
    static let addWeightJP = "体重追加"
    static let addTrainingEN = "training"
    static let addTrainingJP = "筋トレ追加"
    static let addWorkoutEN = "workout"
    static let addWorkoutJP = "有酸素追加"
    
    static let firebaseCollectionNameWeight = "weights"
    static let firebaseCollectionNameTraining = "trainings"
    static let firebaseCollectionNameWorkout = "workouts"
    
    static let identifierMain = "Main"
    static let identifierLogin = "Login"
    static let identifierTableViewCell = "TableViewCell"
    static let identifierCell = "Cell"
    static let identifierAddWeight = "AddWeight"
    static let identifierAddTraining = "AddTraining"
    static let identifierAddWorkout = "AddWorkout"
    static let identifierEditWorkout = "EditWorkout"
    static let identifierTrainingCell = "TrainingCell"
    static let identifierWorkoutCell = "WorkoutCell"
    
    static let colorAccent = "AccentColor"
    static let colorBlack = "Black"
    static let rgbLightBlack = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
    
    static let heightAddMenuCell = 60.0
    
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
