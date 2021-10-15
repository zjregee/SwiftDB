//
//  Entry.swift
//  SwiftDB
//
//  Created by 余润杰 on 2021/10/13.
//

import Foundation

let ENTRY_HEADER_SIZE = 21

struct Entry {
    var meta:      Meta?
    var state:     UInt8?
    var timestamp: UInt64?
    var buf:       [Byte]?
    var flag:      Bool
    
    init(buf: [Byte]) {
        self.buf = buf
        flag = true
    }
    
    init(key: [Byte], value: [Byte], extra: [Byte], state: UInt8, timestamp: UInt64) {
        self.meta = Meta(key: key, value: value, extra: extra, keysize: UInt32(key.count), valuesize: UInt32(value.count), extrasize: UInt32(extra.count))
        self.state = state
        self.timestamp = timestamp
        flag = false
    }
    
    init(key: [Byte], value: [Byte], state: UInt8, timestamp: UInt64) {
        self.meta = Meta(key: key, value: value, extra: [Byte](), keysize: UInt32(key.count), valuesize: UInt32(value.count), extrasize: 0)
        self.state = state
        self.timestamp = timestamp
        flag = false
    }
    
    init(key: [Byte], value: [Byte], state: UInt8, deadline: UInt64) {
        self.meta = Meta(key: key, value: value, extra: [Byte](), keysize: UInt32(key.count), valuesize: UInt32(value.count), extrasize: 0)
        self.state = state
        self.timestamp = deadline
        flag = false
    }
    
    func size() -> Int {
        if let meta = self.meta {
            return ENTRY_HEADER_SIZE + Int(meta.keysize) + Int(meta.valuesize) + Int(meta.extrasize)
        }
        return ENTRY_HEADER_SIZE
    }
    
    mutating func encode() -> Bool {
        if let meta = self.meta, let state = self.state, let timestamp = self.timestamp {
            buf = [Byte]()
            buf?.append(UInt8(meta.keysize >> 24))
            buf?.append(UInt8(meta.keysize >> 16 & 0xff))
            buf?.append(UInt8(meta.keysize >> 8 & 0xff))
            buf?.append(UInt8(meta.keysize & 0xff))
            buf?.append(UInt8(meta.valuesize >> 24))
            buf?.append(UInt8(meta.valuesize >> 16 & 0xff))
            buf?.append(UInt8(meta.valuesize >> 8 & 0xff))
            buf?.append(UInt8(meta.valuesize & 0xff))
            buf?.append(UInt8(meta.extrasize >> 24))
            buf?.append(UInt8(meta.extrasize >> 16 & 0xff))
            buf?.append(UInt8(meta.extrasize >> 8 & 0xff))
            buf?.append(UInt8(meta.extrasize & 0xff))
            buf?.append(state)
            buf?.append(UInt8(timestamp >> 56))
            buf?.append(UInt8(timestamp >> 48 & 0xff))
            buf?.append(UInt8(timestamp >> 40 & 0xff))
            buf?.append(UInt8(timestamp >> 32 & 0xff))
            buf?.append(UInt8(timestamp >> 24 & 0xff))
            buf?.append(UInt8(timestamp >> 16 & 0xff))
            buf?.append(UInt8(timestamp >> 8 & 0xff))
            buf?.append(UInt8(timestamp & 0xff))
            for byte in meta.key {
                buf?.append(byte)
            }
            for byte in meta.value {
                buf?.append(byte)
            }
            for byte in meta.extra {
                buf?.append(byte)
            }
            flag = true
            return true
        }
        return false
    }
    
    mutating func decode() -> Bool {
        if let buf = self.buf {
            if buf.count < ENTRY_HEADER_SIZE {
                return false
            }
            let ks: UInt32 = buf[0..<4].reduce(0) { $0 << 8 + UInt32($1) }
            let vs: UInt32 = buf[4..<8].reduce(0) { $0 << 8 + UInt32($1) }
            let es: UInt32 = buf[8..<12].reduce(0) { $0 << 8 + UInt32($1) }
            let st: UInt8 = buf[12]
            let ts: UInt64 = buf[13..<21].reduce(0) { $0 << 8 + UInt64($1) }
            meta = Meta(key: [Byte](), value: [Byte](), extra: [Byte](), keysize: ks, valuesize: vs, extrasize: es)
            timestamp = ts
            state = st
            return true
        }
        return false
    }
}

struct Meta {
    let key:       [Byte]
    let value:     [Byte]
    let extra:     [Byte]
    let keysize:   UInt32
    let valuesize: UInt32
    let extrasize: UInt32
}
