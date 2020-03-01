//
//  Web3Helper.swift
//  StudyWeb3Swift
//
//  Created by 飯田白米 on 2020/02/29.
//  Copyright © 2020 飯田白米. All rights reserved.
//

import Foundation
import UIKit
import BigInt
import web3swift

//---------------------------------------------------------------
// Web3Helper
//---------------------------------------------------------------
// 単一キーストアによるイーサリアム管理
// このヘルパー自体にはセーブ／ロードの仕組みは持たせない
//（※[I/O]処理は呼び出し元で管理される想定＝独自のファイル処理ができるように）
//---------------------------------------------------------------
class Web3Helper{
    // 接続先
    public enum target {
        case mainnet
        case ropsten
        case rinkeby
        case kovan

        // FIXME [Infura]へのパス（※[https://infura.io]でプロジェクトを作って下記をおきかえてください）
        // メモ：ちょっとしたテストであれば下記のパスをそのままお使いいただけますが、
        //      予告なく使えなくなるかもしれないのでご了承ください（※筆者がうっかりプロジェクトを消してしまう等）
        public func infuraUrl() -> String {
            switch self {
            case .mainnet:
                return "https://mainnet.infura.io/v3/e6eb2fc288634fc3bf9378098aad2115"
            case .ropsten:
                return "https://ropsten.infura.io/v3/e6eb2fc288634fc3bf9378098aad2115"
            case .rinkeby:
                return "https://rinkeby.infura.io/v3/e6eb2fc288634fc3bf9378098aad2115"
            case .kovan:
                return "https://kovan.infura.io/v3/e6eb2fc288634fc3bf9378098aad2115"
            }
        }
        
        public func networkId() -> Int {
            switch self {
            case .mainnet:
                return 1
            case .ropsten:
                return 3
            case .rinkeby:
                return 4
            case .kovan:
                return 42
            }
        }
    }
    
    // 定数（※[cbc]だと[MetaMask]でインポートに失敗するので、暗号モードは[ctr]を指定）
    public let aesMode = "aes-128-ctr"

    // メンバー
    private var web3 : web3?                        // web3インスタンス
    private var curTarget : target?                 // 現在の接続先
    private var curKeystore : EthereumKeystoreV3?   // 現在のキーストア
    private var curAddress : EthereumAddress?       // 現在のアドレス
        
    //-----------------------
    // イニシャライザ
    //-----------------------
    public init() {
        self.web3 = nil
        self.curTarget = nil
        self.curKeystore = nil
        self.curAddress  = nil
    }
    
    //-----------------------
    // 有効性の判定
    //-----------------------
    public func isValid() -> Bool{
        if self.curTarget == nil {
            return false
        }
        
        if self.web3 == nil {
            return false
        }
        
        if self.curKeystore == nil {
            return false
        }
        
        if self.curAddress == nil {
            return false
        }
        
        if self.web3!.provider.attachedKeystoreManager == nil {
            return false
        }
        
        return true
    }
    
    //-----------------------
    // ターゲットのクリア
    //-----------------------
    public func clearTarget() {
        self.web3 = nil
        self.curTarget = nil
    }
    
    //-----------------------
    // ターゲット設定
    //-----------------------
    public func setTarget( target: target ) -> Bool{
        // 古いターゲットは切断
        clearTarget()
        
        let url = URL( string: target.infuraUrl() )
        self.web3 = try? Web3.new( url! )
        
        if self.web3 != nil {
            self.curTarget = target;
            return true
        }

        self.curTarget = nil
        return false
    }
    
    //-----------------------
    // web3取得
    //-----------------------
    public func getWeb3() -> web3?{
        return self.web3;
    }

    //-----------------------
    // ターゲット取得
    //-----------------------
    public func getCurTarget() -> target?{
        return self.curTarget
    }
    
    //-----------------------
    // キーストアのクリア
    //-----------------------
    public func clearKeystore() {
        self.curKeystore = nil
        self.curAddress = nil
    }

    //-----------------------
    // 新規キーストアの作成
    //-----------------------
    public func createNewKeystore( password : String ) -> Bool{
        // 古いキーストアは削除
        self.clearKeystore()
        
        // キーストアの作成
        self.curKeystore = try! EthereumKeystoreV3( password: password, aesMode: self.aesMode )
        self.curAddress = self.curKeystore!.addresses!.first

        // キーストアマネージャにアタッチ
        let keystoreManager = KeystoreManager([self.curKeystore!])
        web3!.addKeystoreManager( keystoreManager )
        
        return isValid()
     }
    
    //-----------------------------------------
    // キーストアの読み込み
    //-----------------------------------------
    public func loadKeystore( json : String ) -> Bool{
        // 古いキーストアは削除
        self.clearKeystore()

        // キーストアの作成
        self.curKeystore = EthereumKeystoreV3( json )
        self.curAddress = self.curKeystore!.addresses!.first
        
        // キーストアマネージャにアタッチ
        let keystoreManager = KeystoreManager([self.curKeystore!])
        web3!.addKeystoreManager( keystoreManager )
        
        return isValid()
    }

    //-----------------------------
    // 現アドレスの取得
    //-----------------------------
    public func getCurAddress() -> EthereumAddress? {
        if !self.isValid() {
            return nil
        }
        
        return self.curAddress
    }

    //-----------------------------
    // 現アドレスのJSON文字列の取得
    //-----------------------------
    public func getCurKeystoreJson() -> String? {
        if !self.isValid() {
            return nil
        }
        
        let data = try! JSONEncoder().encode( self.curKeystore!.keystoreParams )
        return String( data: data, encoding: .ascii )
    }
    
    //-----------------------
    // 現アドレスの秘密鍵の取得
    //-----------------------
    public func getCurPrivateKey( password : String ) -> String? {
        if !self.isValid() {
            return nil
        }

        // 接頭子"0x"のつかない６４文字の１６進文字列が返る（※先頭の値が０でも０埋めされる）
        return try! self.curKeystore!.UNSAFE_getPrivateKeyData( password: password, account: self.curAddress! ).toHexString()
    }

    //--------------------------------
    // 現アドレスのイーサリアムアドレスの取得
    //--------------------------------
    public func getCurEthereumAddress() -> String? {
        if !self.isValid() {
            return nil
        }

        // 接頭子"0x"のついた４０文字の１６進数文字列が返る
        return self.curAddress!.address
    }

    //-----------------------
    // 現アドレスの残高の取得
    //-----------------------
    public func getCurBalance() -> BigUInt{
        if !self.isValid() {
            return 0
        }
        
        do{
            let balance = try self.web3!.eth.getBalance( address: self.curAddress! )
            return balance
        } catch {
            return 0
        }
    }
}
