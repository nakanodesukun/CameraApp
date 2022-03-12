//
//  ViewController.swift
//  CameraApp
//
//  Created by 中野翔太 on 2022/03/12.
//

import UIKit
import RealmSwift
import Photos

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet private weak var pictureImage: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        print(Realm.Configuration.defaultConfiguration.fileURL!)

    }
    @IBAction private func cameraButtonAction(_ sender: Any) {
        switch PHPhotoLibrary.authorizationStatus() {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { status in
                switch status {
                case .authorized:
                    print("Authorized")
                default:
                    print("Other")
                }
            }
        default:
            break
        }
        // カメラかフォトライブラリーどちらの画像を選択するか
        let alertController = UIAlertController(title: "確認", message: "選択してください", preferredStyle: .actionSheet)
        // カメラを利用可能かチェック
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            print("カメラは利用できます")
            // カメラを起動するための選択肢を定義
            let cameraAction = UIAlertAction(title: "カメラ", style: .default, handler: { (action) in
                // UIImagePickerControllerのインスタンスを生成
                let imagePickerController = UIImagePickerController()
                // sorucetypeにcameraを設定
                imagePickerController.sourceType = .camera
                // delegate設定
                imagePickerController.delegate = self
                self.present(imagePickerController, animated: true, completion: nil)
            })
            alertController.addAction(cameraAction)
        }

    if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
        
        print("フォトライブラリーは保存できます")
        //　フォトライブラリーを起動するための選択肢を定義
        let pohotoLibrary = UIAlertAction(title: "フォトライブラリー", style: .default, handler: { (action) in
            // UIImagePickerControllerのインスタンスを生成
            let imagePickerController = UIImagePickerController()
            // sorucetypeにcameraを設定
            imagePickerController.sourceType = .photoLibrary
            // delegate設定
            imagePickerController.delegate = self
            self.present(imagePickerController, animated: true, completion: nil)
        })
        alertController.addAction(pohotoLibrary)
    }
    // ipadで落ちてしまう対策
    alertController.popoverPresentationController?.sourceView = view
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
     // 選択肢を画面に表示
    present(alertController, animated: true, completion: nil)
}

    @IBAction private func shareButtonAction(_ sender: Any) {
        // 表示画像をアンラップして画像を取り出す
        if let shardImage = pictureImage.image {
            // UIActityViewControllerに渡す配列を作成
            let shardItems = [shardImage, "この写真は"] as [Any]
            // UIActivityViewControllerにシェア画像を渡す
            let controller = UIActivityViewController(activityItems: shardItems, applicationActivities: nil)
            // ipadで落ちてしまう対策
            controller.popoverPresentationController?.sourceView = view
            // UIActivityViewControllerを表示
            present(controller, animated: true, completion: nil)
        }

    }

    // 撮影が終わった時に呼ばれるメソッド
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        // 画像ライブラリへのアクセスが許可されていない場合はnilが帰ってくる
        guard let phAsset = info[.phAsset] as? PHAsset else {
            print("エラー")
            return
        }
        let option = PHContentEditingInputRequestOptions()
        phAsset.requestContentEditingInput(with: option) { (input, info) in
            // fullSizeImageURL に選択した画像のURLが入っているのでアンラップします
            guard let url = input?.fullSizeImageURL else {
                return
            }
            do {
                let realm = try Realm()
                let realmUser = RealmUser()
                realmUser.userImageUrl = "\(url)"
                try realm.write({
                    realm.add(realmUser)
                })
            } catch {

            }
            print(url.absoluteString)
        }

        // 撮影した画像を配置したpickerImageViewに渡す
        pictureImage.image = info[UIImagePickerController.InfoKey.originalImage]  as? UIImage
        // モーダルビューを閉じる
        dismiss(animated: true, completion: nil)
    }
}
