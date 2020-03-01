//
//  TestWeb3.swift
//  StudyWeb3Swift
//
//  Created by 飯田白米 on 2020/02/29.
//  Copyright © 2020 飯田白米. All rights reserved.
//

import Foundation
import UIKit
import BigInt
import web3swift

class TestWeb3 {
    //-------------------------
    // メンバー
    //-------------------------
    let helper: Web3Helper              // [web3swift]利用のためのヘルパー
    let keyFile: String                 // 直近に作成されたキーストアを保持するファイル
    let password: String                // アカウント作成時のパスワード
    let targetNet: Web3Helper.target    // 接続先
    var isBusy = false                  // 重複呼び出し回避用

    //-------------------------
    // イニシャライザ
    //-------------------------
    public init(){
        // ヘルパー作成
        self.helper = Web3Helper()
    
        // キーストアファイル
        self.keyFile = "key.json"

        // FIXME ご自身のパスワードで置き換えてください
        // メモ：このコードはテスト用なのでソース内にパスワードを書いていますが、
        //      公開を前提としたアプリを作る場合、ソース内にパスワードを書くことは大変危険です！
        self.password = "password"
                
        // FIXME ご自身のテストに合わせて接続先を変更してください
        self.targetNet = Web3Helper.target.rinkeby
    }

    //-------------------------
    // テストの開始
    //-------------------------
    public func test() {
        // テスト中なら無視
        if( self.isBusy ){
            print( "@ TestWeb3: busy!" )
            return;
        }
        self.isBusy = true;
        
        // キュー（メインとは別のスレッド）で処理する
        let queue = OperationQueue()
        queue.addOperation {
            self.execTest()
            self.isBusy = false;
        }
    }

    //-------------------------
    // テストの開始
    //-------------------------
    func execTest() {
        print( "@--------------------------" )
        print( "@ TestWeb3: start..." )
        print( "@--------------------------" )

        do{
            // 接続先の設定
            self.setTarget()
            
            // キーストア（イーサリアムアドレス）の設定
            self.setKeystore()
            
            // 残高の確認
            self.checkBalance()
            
            // イーサの送信
            try self.checkSend()
            
            // [HelloWorld]コントラクトの確認
            try self.checkHelloWorld()
            
        } catch {
            print( "@ TestWeb3: error:", error )
        }
        
        print( "@--------------------------" )
        print( "@ TestWeb3: finished" )
        print( "@--------------------------" )
    }

    //-----------------------------------------
    // JSONファイルの保存
    //-----------------------------------------
    func saveKeystoreJson( json : String ) -> Bool{
        let userDir = NSSearchPathForDirectoriesInDomains( .documentDirectory, .userDomainMask, true )[0]
        let keyPath = userDir + "/" + self.keyFile
        return FileManager.default.createFile( atPath: keyPath, contents: json.data( using: .ascii ), attributes: nil )
    }
    
    //-----------------------------------------
    // JSONファイルの読み込み
    //-----------------------------------------
    func loadKeystoreJson() -> String?{
        let userDir = NSSearchPathForDirectoriesInDomains( .documentDirectory, .userDomainMask, true )[0]
        let keyPath = userDir + "/" + self.keyFile
        return try? String( contentsOfFile: keyPath, encoding: String.Encoding.ascii )
    }

    //-----------------------------------------
    // 接続先設定
    //-----------------------------------------
    func setTarget(){
        print( "@------------------" )
        print( "@ setTarget" )
        print( "@------------------" )
        _ = self.helper.setTarget( target: self.targetNet )
        
        let target = self.helper.getCurTarget()
        print( "@ target:", target! )
    }

    //-----------------------------------------
    // キーストア設定
    //-----------------------------------------
    func setKeystore() {
        print( "@------------------" )
        print( "@ setKeystore" )
        print( "@------------------" )

        // キーストアのファイルを読み込む
        if let json = self.loadKeystoreJson(){
            print( "@ loadKeystoreJson: json=", json )

            let result = helper.loadKeystore( json: json )
            print( "@ loadKeystore: result=", result )
        }
        
        // この時点でヘルパーが無効であれば新規キーストアの作成
        if !helper.isValid() {
            if helper.createNewKeystore(password: self.password){
                print( "@ CREATE NEW KEYSTORE" )
                
                let json = helper.getCurKeystoreJson()
                print( "@ Write down below json code to import generated account into your wallet apps(e.g. MetaMask)" )
                print( json! )

                let privateKey = helper.getCurPrivateKey( password : self.password )
                print( "@ privateKey:", privateKey! )

                // 出力
                let result = self.saveKeystoreJson( json: json! )
                print( "@ saveKeystoreJson: result=", result )
            }
        }

        // イーサリアムアドレスの確認
        let ethereumAddress = helper.getCurEthereumAddress()
        print( "@ CURRENT KEYSTORE" )
        print( "@ ethereumAddress:", ethereumAddress! )
    }
    
    //------------------------
    // 残高確認
    //------------------------
    func checkBalance() {
        print( "@------------------" )
        print( "@ checkBalance" )
        print( "@------------------" )
        
        let balance = self.helper.getCurBalance()
        print( "@ balance:", balance, "wei" )
    }
    
    //------------------------
    // 送金確認
    //------------------------
    func checkSend() throws{
        print( "@------------------" )
        print( "@ checkSend" )
        print( "@------------------" )

        let web3 = self.helper.getWeb3()
        let sendToAddress = EthereumAddress("0xebfCB28c530a9aAD2e5819d873EB5Cc7b215d1E1")!

        let contract = web3!.contract(Web3.Utils.coldWalletABI, at: sendToAddress, abiVersion: 2)
        let value = Web3.Utils.parseToBigUInt( "0.01", units: .eth )    // 0.01 eth
        let from = self.helper.getCurAddress()
        let writeTX = contract!.write("fallback")!
        writeTX.transactionOptions.from = from
        writeTX.transactionOptions.value = value

        print( "@ try writeTx.sendPromise().wait()" )
        
        let result = try writeTX.sendPromise(password: self.password).wait()
        print( "@ result:", result )
    }

    //------------------------
    // [HelloWorld]確認
    //------------------------
    func checkHelloWorld() throws{
        print( "@------------------" )
        print( "@ checkHelloWorld" )
        print( "@------------------" )

        let contract = ContractHelloWorld()
        
        // [getWord]
        let word = try contract.getWord( self.helper )
        print( "@ [HelloWorld].getWord:", word! )

        // [setWord]
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        
        let sendWard = "Greeting from web3swift at " + formatter.string( from: Date() )
        print( "@ [HelloWorld].sendWord:", sendWard )
        
        // [setWord]の返値はトランザクションとなる（※この時点では[setWord]の書き込みはイーサリアム上で同期されていない点に注意）
        let tx = try contract.setWord( self.helper, password: self.password, word: sendWard )
        print( "@ tx:", tx )
    }
}
