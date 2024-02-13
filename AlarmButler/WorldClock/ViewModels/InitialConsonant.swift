//
//  FilterSectionData.swift
//  AlarmButler
//
//  Created by t2023-m0099 on 2/11/24.
//

import Foundation

//한글 자모를 받아서 해당하는 초성으로 변환
func toInitialConsonant(consonant: String) -> String {
    switch consonant.unicodeScalars.first?.value {
    case 4352:
        return "ㄱ"
    case 4354:
        return "ㄴ"
    case 4355:
        return "ㄷ"
    case 4357:
        return "ㄹ"
    case 4358:
        return "ㅁ"
    case 4359:
        return "ㅂ"
    case 4361:
        return "ㅅ"
    case 4363:
        return "ㅇ"
    case 4364:
        return "ㅈ"
    case 4366:
        return "ㅊ"
    case 4367:
        return "ㅋ"
    case 4368:
        return "ㅌ"
    case 4369:
        return "ㅍ"
    case 4370:
        return "ㅎ"
    default:
        return""
    }
}
