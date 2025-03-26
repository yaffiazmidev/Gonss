//
//  StringEnum.swift
//  KipasKipasDirectMessageUI
//
//  Created by DENAZMI on 31/07/23.
//

import Foundation

enum StringEnum: String {
    case blockUser = "Blokir Pengguna"
    case blockUserAlertMessage = "tidak akan bisa lagi mengirim pesan, tapi masih bisa melihat profil dan post milikmu. Apakah kamu masih ingin memblokir "
    case deleteChat = "Hapus Chat"
    case openBlockUser = "Buka Blokir Pengguna"
    case passwordInvalid = "Password tidak sesuai"
    case passwordFreeze = "Kamu sudah 5x memasukan password yang salah, tunggu 10 menit kemudian untuk mencoba kembali"
    case withdrawalLimitPerDay = "Tidak bisa melakukan penarikan lebih dari 2x dalam sehari"
    case sessionExpired = "Sesi telah berakhir"
    case paidMessageExpired = "Sesi telah berakhir sebelum kamu mengirim pesan ini, apakah kamu masih ingin membalas pesan ini atau membatalkan pesan yang kamu kirim?"
}
