//
//  Hash.swift
//  SwiftDB
//
//  Created by 余润杰 on 2021/10/13.
//

import Foundation

// 单线程
// 0 未作出改变
// 1 发生了改变

typealias Byte = UInt8
typealias Record = [String: [String: [Byte]]]

class Hash {
    
    private var record: Record
    
    init() {
        record = Record()
    }
    
    init(record: Record) {
        self.record = record
    }
    
    func HSet(key: String, field: String, value: [Byte]) -> Int {
        if !exist(key: key) {
            record[key] = [String: [Byte]]()
        }
        
        record[key]![field] = value
        return 1
    }
    
    func HSetNx(key: String, field: String, value: [Byte]) -> Int {
        if !exist(key: key) {
            record[key] = [String: [Byte]]()
        }
        
        if !record[key]!.keys.contains(field) {
            record[key]![field] = value
            return 1
        }
        return 0
    }
    
    func HGet(key: String, field: String) -> [Byte]? {
        if let record = record[key] {
            return record[field]
        }
        return nil
    }
    
    func HGetAll(key: String) -> [[Byte]]? {
        if let record = record[key] {
            var res = [[Byte]]()
            for e in record {
                res.append([Byte](e.key.utf8))
                res.append(e.value)
            }
            return res
        }
        return nil
    }
    
    func HDel(key: String, field: String) -> Int {
        if !exist(key: key) {
            return 0
        }
        
        if record[key]!.keys.contains(field) {
            record[key]!.removeValue(forKey: field)
            return 1
        }
        return 0
    }
    
    func HKeyExists(key: String) -> Bool {
        return exist(key: key)
    }
    
    func HExists(key: String, field: String) -> Bool {
        if let record = record[key] {
            if record.keys.contains(field) {
                return true
            }
        }
        return false
    }
    
    func HLen(key: String) -> Int {
        if let record = record[key] {
            return record.count
        }
        return 0
    }
    
    func HKeys(key: String) -> [String]? {
        if let record = record[key] {
            var res = [String]()
            for e in record {
                res.append(e.key)
            }
            return res
        }
        return nil
    }
    
    func HVals(key: String) -> [[Byte]]? {
        if let record = record[key] {
            var res = [[Byte]]()
            for e in record {
                res.append(e.value)
            }
            return res
        }
        return nil
    }
    
    func HClear(key: String) -> Int {
        if !exist(key: key) {
            return 0
        }
        record.removeValue(forKey: key)
        return 1
    }
    
    private func exist(key: String) -> Bool {
        return record.keys.contains(key)
    }
    
}
