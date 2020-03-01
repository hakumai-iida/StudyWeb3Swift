//
//  ContractHelloWorld.swift
//  StudyWeb3Swift
//
//  Created by 飯田白米 on 2020/02/29.
//  Copyright © 2020 飯田白米. All rights reserved.
//

import Foundation
import UIKit
import BigInt
import web3swift

//-------------------------------------------------------------
// [HelloWorld.sol]
//-------------------------------------------------------------
class ContractHelloWorld {
    //--------------------------------
    // [abi]ファイルの内容
    //--------------------------------
    internal let abiString = """
[
  {
    "inputs": [
      {
        "internalType": "string",
        "name": "_word",
        "type": "string"
      }
    ],
    "payable": false,
    "stateMutability": "nonpayable",
    "type": "constructor"
  },
  {
    "constant": true,
    "inputs": [],
    "name": "word",
    "outputs": [
      {
        "internalType": "string",
        "name": "",
        "type": "string"
      }
    ],
    "payable": false,
    "stateMutability": "view",
    "type": "function"
  },
  {
    "constant": true,
    "inputs": [],
    "name": "getWord",
    "outputs": [
      {
        "internalType": "string",
        "name": "",
        "type": "string"
      }
    ],
    "payable": false,
    "stateMutability": "view",
    "type": "function"
  },
  {
    "constant": false,
    "inputs": [
      {
        "internalType": "string",
        "name": "_word",
        "type": "string"
      }
    ],
    "name": "setWord",
    "outputs": [],
    "payable": false,
    "stateMutability": "nonpayable",
    "type": "function"
  }
]
"""

    //--------------------------------
    // コントラクトの取得
    //--------------------------------
    internal func getContract( _ helper:Web3Helper ) -> web3.web3contract? {
        var address:String
        
        // FIXME ご自身がデプロイしたコントラクトのアドレスに置き換えてください
        // メモ：[rinkeby]のアドレスは実際に存在するコントラクトなので、そのままでも利用できます
        switch helper.getCurTarget()! {
        case Web3Helper.target.mainnet:
            address = ""
            
        case Web3Helper.target.ropsten:
            address = ""

        case Web3Helper.target.kovan:
            address = ""

        case Web3Helper.target.rinkeby:
            address = "0xd21ce6f369f8281b7d39b47372c8f4a8a77841fc"
        }
        
        let contractAddress = EthereumAddress( address )
        
        let web3 = helper.getWeb3()
        
        let contract = web3!.contract( abiString, at: contractAddress, abiVersion: 2 )
        
        return contract
    }
    
    //---------------------------------------------------
    // getWord
    //---------------------------------------------------
    // 引数：なし
    // 返値：文字列
    //---------------------------------------------------
    public func getWord( _ helper:Web3Helper ) throws -> String?{
        let contract = getContract( helper )
        
        // [getWord]は[view]なので[read]で呼び出す
        let tx = contract!.read( "getWord" )
        
        let response = try tx!.callPromise().wait()
        
        return response["0"] as? String
    }
    
    //---------------------------------------------------
    // setWord
    //---------------------------------------------------
    // 引数：文字列
    // 返値：なし
    //---------------------------------------------------
    public func setWord( _ helper:Web3Helper, password:String, word:String ) throws -> TransactionSendingResult {
        let contract = getContract( helper )
        
        let parameters = [word] as [AnyObject]
        let data = Data()
        var options = TransactionOptions.defaultOptions
        options.from = helper.getCurAddress()

        // [setWord]はブロックチェーンに書き込むので[write]で呼び出す
        let tx = contract!.write( "setWord", parameters: parameters, extraData:data, transactionOptions: options )

        // [wirte]の結果はトランザクションで返る（※この時点ではブロックチェーン上で同期されている保証はない）
        let response = try tx!.sendPromise( password: password ).wait()
        return( response );
    }
}
