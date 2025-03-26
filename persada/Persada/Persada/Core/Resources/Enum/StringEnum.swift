//
//  KeyStringEnum.swift
//  KipasKipas
//
//  Created by Daniel Partogi on 28/08/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation

enum StringEnum : String {
	case KipasKipas
	case seleb
	case news
	case following
	case shop = "Shop"
	case tiktok = "Tik-Tok"
	case channels
	case shopping
	case home
	case feed = "Feed"
	case notification
	case statusTransaction = "Status Transaksi"
	case detailTransaction = "Detail Transaction"
	case complaint = "Komplain"
	case sendComplaint = "Kirim Komplain"
	case cancelOrder = "Tolak Pesanan"
	case chooseChannel = "Pilih Channel"
	case deskripsi = "Deskripsi"
	case dimensi = "Dimensi"
	case berat = "Berat"
	case report
	case post = "Post"

	case username = "Username"
	case email = "Email"
	case phone = "Phone"
	case simpan = "Simpan"
	case batalkan = "Batalkan"
	case simpanEmail = "Simpan Email"
	case errorEmail = "Masukan alamat email agar kamu bisa menggunakan fitur lanjutan di aplikasi KipasKipas"
	case simpanEmailDescription = "Pastikan email yang kamu simpan sudah benar, karena untuk sementara anda tidak akan bisa merubah email yang sudah tersimpan."
	case topUp = "Top up"
	case addGopayAccount = "Tambahkan Akun Gopay"
	case sellerSaldo = "Saldo Penjualan"
	case refundSaldo = "Saldo Refund"
	case social = "Social"
	case transaction = "Transaction"
    
	case registerLabel = "Daftar"
	case registerBg = "registerBG"
	case registerInputNumberLabel = "Masukan nomor telfon kamu."
	case registerHint = "085xxxxxxxxx"
	case registerBtnTitle = "Register"
	case haveAccountLabel = "Sudah punya akun?"
	case numberCantEmpty = "Nomor tidak boleh kosong"
	case numberCantLessThanTen = "Nomor tidak boleh kurang dari 10"
	case numberFormatNotValid = "Format nomor tidak sesuai"
	case prefix08 = "08"
	case otpLimitation = "Kamu sudah 3 kali meminta OTP, coba \nlagi besok ya"

	case signIn = "Masuk"
	case signInWithGoogle = "Masuk dengan Google"
	case signInWithFb = "Masuk dengan Facebook"
	case warning = "Warning"
	case ok = "OK"
	case cancel = "cancel"
	case numberHasBeenUsed = "No HP sudah digunakan"

	case namePlaceholder = "Your Name"
	case userNamePlaceholder = "Your UserName"
	case passwordPlaceholder = "Your Password"
	case fullNameText = "Full Name"
	case userNameText = "username"
	case passwordText = "Password"
	case letsGo = "Let's go"
    
	case photoUpload = "Upload Foto"
	case setupProfile = "Atur profile untuk mulai interaksi dengan idola kamu."
    
	case send = "Kirim"
	case loginFailed = "Password atau username tidak sesuai"
	case passwordMin8Char = "Password minimal 8 karakter"
	case attention = "Attention"
	case pleaseFillPassword = "Harap masukan password"
	case pleaseFillUsername = "Harap masukkan username"
	case forgotPassword = "Lupa Password?"
	case dontHaveAccount = "Belum Punya Akun?"
	case loginBg = "LoginBG"
	
	case zero = "0"
	case phonePrefix = "62"
	case error = "Error"
	case errorUnknown = "Error tidak diketahui"

	case cellID = "cellId"
	case cariAlamatPlaceholder = "Cari Alamat.."
	
	//address Edit/Add Form
	case labelAlamatPlaceholder = "Masukan label alamat"
	case labelAlamat = "Label Alamat"
	
	case namaPenerimaPlaceholder = "Masukan nama penerima"
	case namaPenerima = "Nama Penerima"
	
	case alamatPlaceholder = "Tulis detail alamat"
	case alamat = "Alamat"
	
	case provinsiPlaceholder = "Masukan provinsi"
	case provinsi = "Provinsi"
	
	case kotaKabupatenPlaceholder = "Masukan kota / kabupaten"
	case kotaKabupaten = "Kota / Kabupaten"
	
	case kecamatanPlaceholder = "Masukan kecamatan"
	case kecamatan = "Kecamatan"
	
	case kodePosPlaceholder = "123xx"
	case kodePos = "Kode Pos"
	
	case nomorTeleponPlaceholder = "08xx-xxxx-xxxx"
	case nomorTelepon = "Nomor Telepon"
	
	case hapusAlamat = "Hapus Alamat"
	case tambahAlamatWithPlus = "+ Tambah Alamat"
	case kamuBelumMenambahkanAlamat = "Kamu belum \nmenambahkan alamat"
	case belumAdaAlamatTerpilih = "Belum ada alamat terpilih"
	
	case tambahAlamatPengiriman = "Tambah Alamat Pengiriman"
	case tambahAlamat = "Tambah Alamat"
	//end of address Edit/Add Form
	
	case alamatUtama = "Alamat Utama"
	case ubahAlamat = "Ubah Alamat"
	case tambah = "Tambah"
	case apakahAndaYakin = "Apakah anda yakin ingin menghapus alamat Anda ?"
	case diKirimKe = "Dikirim Ke"
	
	case filter = "Filter"
	case filter3Month = "Hanya menampilan data 3 bulan kebelakang, dihitung dari hari ini"
	case dariTanggal = "Dari Tanggal"
	case sampaiTanggal = "Sampai Tanggal"
	case implmentedFilter = "Terapkan Filter"
	case datePlaceholder = "DD/MM/YYYY"
	case uangMasuk = "Uang Masuk"
	case penarikan = "Penarikan"
	case typeOfTransaction = "Jenis Penarikan"
	
	case confirmMessage = "Konfirmasi Pesanan"
	case confirmationTransactionPurchase = "Lakukan konfirmasi ini hanya jika pesanan sudah benar-benar anda terima dengan baik dan lengkap, karena transaksi akan dianggap selesai dan dana akan diteruskan ke penjual."
	case done = "Selesai"
	case back = "Kembali"
	
	case createdStory = "Buat Story"
	case createdPost = "Buat Post"
	case sharedPost = "Bagikan sebagai Post"
	case sharedStory = "Bagikan sebagai story"
	case sharedAnotherMedia = "Share ke media lain"
	case sendToDM = "Kirim ke DM"
	case archiveProduct = "Arsipkan produk"
	case editProduct = "Edit produk"
	
	case chooseCourierAndDuration = "Pilih Kurir & Durasi Pengiriman"
	case likedYourPost = "Liked your post."
	case likedYourComment = "Liked your comment."
	case writeCaption = "Tulis Caption"
	case captionShouldNotBeEmpty = "Caption tidak boleh kosong"
	case productNamePricAndDescriptionCantEmpty = "Nama, harga dan deskripsi tidak boleh kosong"
	case inputProductDesc =  "Isi deskripsi barangmu"
	case settingPosting = "Atur postingan"
	
	case errorDefault = "Something Went Wrong, Try again later"

	case masukAplikasi = "Masuk ke aplikasi"
	case loginFirst = "Anda harus login terlebih dahulu\nuntuk menggunakan fitur ini"

	case accountReported = "Anda sudah melakukan report terhadap post ini"
    case thanskReport = "Terima kasih atas laporan\nyang kamu berikan"
    case reportInfo = "Laporan kamu sangat membantu dalam\nmenciptakan social media yang positif."
    case backToHome = "Kembali ke Home"
}
