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
	case following = "Following"
	case shop = "Shop"
	case tiktok = "Tik-Tok"
    case cleeps = "Cleeps 🇮🇩"
    case hotnews = "Hotnews"
    case hotRoom = "HotRoom"
    //case cleepsCN = "Cleeps 🇨🇳"
    case cleepsCN = "Global 🌏"
    case cleepsKorea = "Cleeps 🇰🇷"
    case cleepsThai = "Cleeps 🇹🇭"
	case channels
	case shopping
	case home
	case feed = "Feed"
    case trending = "Trending"
	case notification
	case statusTransaction = "Status Transaksi"
	case detailTransaction = "Detail Pesanan"
    case orderComplete = "Order Selesai"
	case complaint = "Komplain"
	case sendComplaint = "Kirim Komplain"
	case cancelOrder = "Tolak Pesanan"
	case chooseChannel = "Pilih Channel"
	case deskripsi = "Deskripsi"
	case dimensi = "Dimensi"
	case berat = "Berat"
	case pesanan = "Pesanan"
	case pesananBaru = "Pesanan Baru"
	case diproces = "Diproses"
	case dikirim = "Dikirim"
	case batal = "Batal"
	case pengirim = "Pengiriman"
	case invoice = "Invoice"
	case report
    case reportAndBlock = "Report & Block"
	case post = "Post"
	case posting = "Posting"
	case follower = "Followers"
	case explore = "Explore"
	case forYou = "For You"
	case follow = "Follow"
	case unfollow = "Unfollow"
	case logo = "Logo"
	case channelGeneral = "Channel General"
	case yourChannel = "Your Channel"
	case buy = "Beli"
    case buyNow = "Beli Sekarang"
    case deleteAccount = "Delete Account"
    case hapusAkun = "Hapus Akun"
    case refresh = "Refresh"
    case errorCourier = "Gunakan tombol refresh dibawah ini untuk mencoba menampilkan list kurir dan durasi pengiriman yang tersedia."

	case username = "Username"
	case email = "Email"
    case yourEmail = "Your Email"
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
    case transaksi = "Transaksi"
	case unknown = "Unknown"
	case checkout = "Checkout"
	case donation = "Donasi"
	case emptyUserProfilePost = "Belum ada postingan"
    case emptyProductOnChat  = "Kamu belum memiliki produk apapun"
	case dontHaveAFollowers = "Belum ada followers"
	case dontHaveAFollowings = "Belum mengikuti siapapun"
	
	case findFollowers = "Cari pengguna"
	case findFollowing =  "Cari following.."
    
	case registerLabel = "Daftar"
	case registerBg = "registerBG"
	case registerInputNumberLabel = "Masukan nomor telfon kamu."
	case registerHint = "085xxxxxxxxx"
	case registerBtnTitle = "Register"
	case haveAccountLabel = "Sudah punya akun?"
	case numberCantEmpty = "Nomor tidak boleh kosong"
	case numberCantLessThanTen = "Nomor tidak boleh kurang dari 10"
	case numberFormatNotValid = "Format nomor tidak sesuai"
    case numberFormatMaxMinError = "Nomor telfon harus 9 sampai 14 karakter"
	case prefix08 = "08"
    case otpNotMatch = "Kode OTP tidak sesuai"
	case otpLimitation = "Kamu sudah melakukan 3x request OTP, coba \nlagi setelah 60 menit"
    case otpInputLimitation = "Kamu sudah 3x memasukan kode yang salah,\ncoba kirim ulang kode"
    case fullnameNotEmpty = "Field nama lengkap tidak boleh kosong"
    case registeredMobileNumber = "Masukan nomor HP yang terdaftar"
    case birthDateShouldNotEmpty = "Birth date tidak boleh kosong"
    case emailShouldNotEmpty = "Email tidak boleh kosong"
    case usernameNotEmpty = "Field username tidak boleh kosong"
    case passwordNotEmpty = "Field password tidak boleh kosong"
    case fieldNotEmpty = "Field tidak boleh kosong"

	case signIn = "Masuk"
	case signInWithGoogle = "Masuk dengan Google"
	case signInWithFb = "Masuk dengan Facebook"
	case signInWithApple = "Masuk dengan Apple"
	case warning = "Warning"
	case ok = "OK"
	case cancel = "Cancel"
    case doneWord = "Done"
	case numberHasBeenUsed = "No HP sudah digunakan"

	case namePlaceholder = "Your Name"
	case usernamePlaceholder = "Your Username"
    case userNameOrMobileNumberPlaceholder = "Username atau No. HP"
	case passwordPlaceholder = "Your Password"
    case birthDatePlaceHolder = "Your birth date"
	case fullNameText = "Full Name"
	case userNameText = "username"
	case passwordText = "Password"
	case letsGo = "Let's go"
    
	case photoUpload = "Upload Foto"
	case setupProfile = "Atur profile untuk mulai interaksi dengan idola kamu."
	
	case detailCourier = "Detail Pengiriman"
	case detailProcessCourier = "Detail Proses Pengiriman"
	case detailTransactionSalesDone = "Pengiriman Selesai"
    
	case send = "Kirim"
	case loginFailed = "Password atau username tidak sesuai"
	case passwordMin8Char = "Password minimal 8 karakter"
    case passwordMin6Char = "Password minimal 6 karakter"
	case attention = "Attention"
	case pleaseFillPassword = "Harap masukan password"
	case pleaseFillUsername = "Harap masukkan username"
    case pleaseFillUsernameAndPassword = "Username dan Passsword belum diisi"
	case forgotPassword = "Lupa Password?"
	case dontHaveAccount = "Belum Punya Akun?"
	case loginBg = "LoginBG"
    case passwordValid = "Password min 6 karakter, kombinasi huruf besar, huruf kecil, dan angka"
    case usernameValid = "Username Tidak bisa hanya menggunakan angka"
    case emailNotValid = "Format email tidak sesuai (example@mail.com)"
    case errorUsernameNotAllowSpecialCharacterAtFirstOrLast = "Username min 4 karakter, hanya bisa menggunakan huruf dan angka. Penggunaan underscore dan titik hanya bisa di tengah."
	
	case zero = "0"
	case phonePrefix = "62"
    case error = "Error"
	case errorTitle = "Ups, sepertinya ada kesalahan!"
    case errorServer = "Telah terjadi kendala pada server kami. Saat ini kami sedang mencoba memperbaikinya, silahkan coba lagi setelah beberapa saat."
	case errorUnknown = "Error tidak diketahui"
	case userNotFound = "User tidak ditemukan"

	case cellID = "cellId"
	case cariBerita = "Cari berita.."
	case cariApa = "Cari apa.."
    case cariProduk = "Cari produk.."
    case cariSiapa = "Cari siapa.."
	case alamatSaya = "Alamat Saya"
    case alamatPenerima = "Alamat Penerima"
	case cariAlamatPlaceholder = "Cari Alamat.."
	case namaAlamat = "Nama Alamat"

	//address Edit/Add Form
	case labelAlamatPlaceholder = "Masukan label alamat"
	case labelAlamat = "Label Alamat"
	
	case namaPenerimaPlaceholder = "Masukan nama penerima"
	case namaPenerima = "Nama Penerima"
	
	case alamatPlaceholder = "Tulis detail alamat"
	case alamat = "Alamat"
	
	case provinsiPlaceholder = "Pilih provinsi"
	case provinsi = "Provinsi"
	
	case kotaKabupatenPlaceholder = "Pilih kota / kabupaten"
	case kotaKabupaten = "Kota / Kabupaten"
	
	case kecamatanPlaceholder = "Pilih kecamatan"
	case kecamatan = "Kecamatan"
	
	case kodePosPlaceholder = "xxxxxxxx"
	case kodePos = "Kode Pos"
	
	case area = "Area"
	
	case nomorTeleponPlaceholder = "08xx-xxxx-xxxx"
	case nomorTelepon = "Nomor Telepon"
	
    case errorVarifyPassword = "Verifikasi password gagal, silahkan coba lagi"
    case hapusRekening = "Hapus Rekening"
	case hapusAlamat = "Hapus Alamat"
	case tambahAlamatWithPlus = "+ Tambah Alamat"
	case kamuBelumMenambahkanAlamat = "Kamu belum \nmenambahkan alamat"
	case belumAdaAlamatTerpilih = "Belum ada alamat terpilih"
	
	case tambahAlamatPengiriman = "Tambah Alamat Pengiriman"
	case tambahAlamat = "Tambah Alamat"
	case pilihAlamatLain = "Pilih Alamat Lain"
	//end of address Edit/Add Form
	
	case alamatUtama = "Alamat Utama"
	case ubahAlamat = "Ubah Alamat"
    case tambahAlamatToko = "Tambah Alamat Toko"
    case editAlamatToko = "Edit Alamat Toko"
	case tambah = "Tambah"
	case apakahAndaYakin = "Apakah anda yakin ingin menghapus alamat Anda ?"
	case diKirimKe = "Dikirim Ke"
	
	case rumah = "Rumah"
	case filter = "Filter"
	case filter3Month = "Hanya menampilan data 3 bulan kebelakang, dihitung dari hari ini"
	case dariTanggal = "Dari Tanggal"
	case sampaiTanggal = "Sampai Tanggal"
	case implmentedFilter = "Terapkan Filter"
	case datePlaceholder = "DD/MM/YYYY"
	case uangMasuk = "Uang Masuk"
	case penarikan = "Penarikan"
    case penarikanDana = "Penarikan Data"
	case typeOfTransaction = "Jenis Penarikan"
	case requestPickUp = "Request Pick Up"
	
    case confirm = "Konfirmasi"
	case confirmMessage = "Konfirmasi Pesanan"
    case confirmDeleteAccountBank = "Yakin ingin menghapus rekening ini?"
	case confirmationTransactionPurchase = "Lakukan konfirmasi ini hanya jika pesanan sudah benar-benar anda terima dengan baik dan lengkap, karena transaksi akan dianggap selesai dan dana akan diteruskan ke penjual."
	case done = "Selesai"
	case back = "Kembali"
    case addReview = "Berikan Ulasan"
    case hasReview = "Sudah Memberi Ulasan"
	
	case priceTermsContent = "Saldo akan bertambah setelah dikonfirmasi oleh pembeli, akan ada pengurangan saldo jika terjadi penyesuaian harga pada saat pengiriman"
	case processNewOrderTermsContent = "Pesanan akan dibatalkan secara otomatis dalam 1x24 jam jika kamu tidak segera memproses pesanan ini"
	case processNotReadyTermContent = "Pesanan akan dibatalkan secara otomatis dalam 2x24 jam jika kamu belum mengirim pesanan ini."
	
	case priceAdjustTerms = "Ketentuan penyesuaian harga"
	case processAdjustTerm = "Ketentuan proses pesanan"
	
	case createdStory = "Buat Story"
	case createdPost = "Buat Post"
	case sharedPost = "Bagikan sebagai Post"
	case sharedStory = "Bagikan sebagai story"
	case sharedAnotherMedia = "Share ke media lain"
	case sendToDM = "Kirim ke DM"
	case archiveProduct = "Arsipkan produk"
	case editProduct = "Edit produk"
    case choiceProduct = "Pilih Produk"
    case setProductReseller = " produk untuk Reseller"
    case createNewProduct = "Buat Produk Baru"
    case addResellerProduct = "Tambah Produk Reseller"
    case stopBecomeReseller = "Berhenti jadi Reseller"
    case productForReseller = "Produk untuk Reseller"
    case productReseller = "Product Reseller"
    case detailCommission = "Detail Komisi"

	case editPost = "Edit Post"
	case deletePost = "Hapus"
	case commenter = "Komentar"
	
	case chooseCourierAndDuration = "Pilih Kurir & Durasi Pengiriman"
	case likedYourPost = "Liked your post."
	case likedYourComment = "Liked your comment."
	case writeCaption = "Tulis Caption"
	case captionShouldNotBeEmpty = "Caption tidak boleh kosong"
	case uploadMinimal1Photo = "Minimal unggah 1 foto"
	case productNamePricAndDescriptionCantEmpty = "Nama, harga dan deskripsi tidak boleh kosong"
	case lengthWidthHeightAndWeightCantEmpty = "Panjang, Lebar, Tinggi dan Berat tidak boleh kosong"
	case inputProductDesc =  "Isi deskripsi barangmu"
	case settingPosting = "Atur postingan"
	case placeholderComment = "Tulis Komentar"
	
	case errorDefault = "Something Went Wrong, please try again.."

	case masukAplikasi = "Masuk ke aplikasi"
	case loginFirst = "Anda harus login terlebih dahulu\nuntuk menggunakan fitur ini"
    case cleepsHabis = "Rekomendasi cleeps sudah habis!!"

	case accountReported = "Anda sudah melakukan report terhadap post ini"
	case new = "NEW"
    case iconWarning = "iconWarning"
    
    case noInternet = "Koneksi internet tidak tersedia"
    case noInternetAvailable = "Silahkan periksa kembali jaringan Wi-Fi atau data kamu"
    
    case thanskReport = "Terima kasih atas laporan\nyang kamu berikan"
    case reportInfo = "Laporan kamu sangat membantu dalam\nmenciptakan sosial media yang positif."
    case backToHome = "Kembali ke Home"
	
	case nolper30 = "0/30"
	case catatan = "Catatan"
	case asuransi = "Gunakan asuransi pengiriman agar produk yang kamu beli aman dari resiko apapun di perjalanan."
	case metodePembayaran = "Metode Pembayaran"
	case durasiPengiriman =  "Durasi Pengiriman"
	
	case subTotal = "Subtotal"
	case biayaKirim = "Biaya Kirim"
	case total = "Total"
	
	case pilihKurirTerlebihDahulu = "Pilih kurir terlebih dahulu"
	case pilihKurir = "Pilih Kurir"
	case notesPlaceholder = "Detail lokasi, warna, varian, dll"
    case emptyComment = "Tambahkan Komentar"
    
    case phoneNumberNotFound = "No HP tidak terdaftar"
    case showMoreAccount = "Lihat lebih banyak"
    case emptyAddress = "Tambahkan alamat pengiriman dari toko kamu untuk mulai jualan di KipasKipas"
    case shopAddress = "Alamat Toko"
    case addAddress = "Tambahkan Alamat"
    case emptyProduct = "Anda belum menambahkan\nproduk apapun"
    case addProduct = "Tambah Produk"
	case caraBayar = "Cara Bayar"
	case caraBayarStep = "1. Masukkan kartu ATM BCA\n2. Masukkan PIN ATM BCA Anda\n3. Pilih menu “TRANSAKSI LAINNYA“\n4. Pilih menu “TRANSFER“\n5. Pilih menu “KE REK. BCA VIRTUAL ACCOUNT“\n6. Masukkan nomor Virtual Account yang Anda terima dari PT Intimap, kemudian pilih “BENAR“\n7. Pastikan data Virtual Account Anda benar, kemudian masukkan angka yang perlu Anda bayarkan, kemudian pilih “BENAR“\n8. Cek & Perhatikan Konfirmasi Pembayaran dari layar ATM, jika sudah benar pilih “YA“, atau pilih “TIDAK” jika data di layar masih salah\n9. Transaksi Anda sudah selesai, pilih “TIDAK” untuk tidak melanjutkan transaksi lain.\n10. Terakhir jangan lupa ambil Kartu ATM BCA Anda."
    case downloadInvoiceMessage = "Invoice Downloaded"
    case pengembalianDana = "Pengembalian Dana"
    case myStoreSetting = "Pengaturan Toko"
    case placeHolderSearch = "Cari Pengaturan.."
	case confirmCanceledOrder = "Konfirmasi Tolak Pesanan"
	case showBarcodeSeller = "Lihat Resi Pengiriman"
    
    case success = "Success"
    case open = "Open"
    case failed = "Failed"
    
    case qrshareimage = "Bagikan sebagai QR Code"
    case qrsaveimage = "Simpan sebagai QR Code"
    case qrsavesuccess = "QR Code has been saved to your photos"
    
    case photosask = "Select more photos or go to Settings to allow access to all photos."
    case photosaccessall = "Allow access to all photos"
    case photosselected = "Select more photos"
    
    case gallerychoose = "Pilih dari gallery"
    
    case cameranotsupportedtitle = "Scanning not supported"
    case cameranotsupportedmsg = "Your device does not support scanning a code from an item. Please use a device with a camera."
    
    case pasangPinPoint = "Pasang Pin Point"
    case pinPointDescription = "Khusus untuk pengiriman express dan alamat yang lebih akurat"
    case aturSebagaiAlamatUtama = "Atur sebagai alamat utama"
    case pinPoint = "Pin Point"
	
	case lottie = "Lottie"
    case aturPinPoint = "Atur Pin Point"
    
    case anteraja = "ANTERAJA"
    case jnt = "JNT"
    case jne = "JNE"
    case sicepat = "SICEPAT"
    case orderInfo = "Untuk pengiriman Same Day lebih dari jam 14:00 WIB kemungkinan akan dikirim hari selanjutnya"
    
    case seeProduct = "See Product"
    case archiveProducts = "Arsip Produk"
    case popUpXib = "DefaultPopViewController"
    case myProductPopupXib = "MyProductPopupViewController"
    case failBuyingProduct = "Produk tidak dapat dibeli"
    case productArchive = "Produk Diarsipkan"
    case activeProduct = "Aktifkan produk"
    case deleteProduct = "Hapus produk"
    case productAlamat = "Alamat pengiriman produk"
    case productKurir = "Kurir yang digunakan"
    case placeHolderSearchArchiveProduct = "Cari.."
    case stockEmpty = "Stok produk tidak tersedia"
    case stockNotEnoughtTitle = "Stok Tidak Mencukupi"
    case stockNotEnoughtDesc = "Hal ini bisa saja terjadi karena stok yang kamu pilih sebelumnya sudah berkurang jumlahnya atau sudah habis ketika kamu sedang mengisi detail pembelian"
    case backToDetail = "Kembali ke detail produk"
    
    case lihatLiveProduct = "Lihat Live Product"
    case produkTidakTersedia = "Produk tidak tersedia"
//    case produkTidakTersediaDeskripsi = "Kemungkinan produk sudah diarsipkan atau dihapus oleh seller."
    case produkTidakTersediaDeskripsi = "Toko ini belum memiliki satupun produk"
    case produkHabis = "Produk Habis"
    
    case tracking = "Tracking"
	
	case askingReport = "Mengapa anda ingin melaporkan postingan ini?"
    case askingReportAccount = "Mengapa anda ingin melaporkan akun ini?"
    case pleaseSelectYourReason = "Please, select your reason"
    case reportAndHidePost = "Lapor & Sembunyikan Postingan"
    case writeReason = "Tulis Alasan"
    
    case pilihAlamat = "Pilih Alamat"
    case alamatNotChoosen = "Silahkan pilih alamat terlebih dahulu sebelum memilih kurir"
    
    case dataBelumLengkap = "Data belum lengkap!"
    case dataBelumLengkapDesc = "Silahkan pilih alamat dan kurir sebelum melanjutkan"
    
    case lanjutkanTransaksi = "Lanjutkan Transaksi"
    case lihatTransaksiYangBelumSelesai = "Lihat transaksi yang belum selesai"
    case transaksiTertunda = "Transaksi tertunda"
    case transaksiTertundaDesc = "Jika kamu melanjutkan pembelian ini, maka pembelian barang yang belum kamu selesaikan akan dibatalkan secara otomatis oleh sistem."
    
    case productNotAvailableDesc = "Kemungkinan produk sudah diarsipkan atau dihapus oleh seller"
    case berhasil = "Berhasil"
    case productActiveDesc = "Product Berhasil diaktifkan"
    case productAddDesc = "Product Berhasil ditambahkan"
    case uploadSuccessfull = "Upload Successfull"
    case uploadSucessfullMessage = "Product berhasil ditambahkan ke-Story"
    case uploadPostProductSucessfullMessage = "Product berhasil ditambahkan ke-Post"
    case menghapusProduk = "Menghapus Produk"
    case menghapusProduKDescription = "Produk yang dihapus tidak akan bisa kamu lihat kembali."
    case hapusProduk = "Hapus Produk"
    
    case tittleTrashProduct = "Produk sudah dihapus"
    case captionTrashPoduct = "Produk telah kamu hapus dari arsip."
    case backArchiveProduct = "Kembali ke Etalase"
	
	case titleCancelSalesItem = "Mengapa anda ingin menolak pesanan ini?"
	case backToShop = "Kembali ke Shop"
	case orderAlreadyCanceled = "Pesanan Sudah Dibatalkan"
	case dontGiveupYourShop = "Jangan lesu, ayo lakukan yang terbaik agar toko kamu jadi salah satu toko paling hits di KipasKipas."
	case writeYourReason =  "Tuliskan Alasan anda..."
	case otherReason = "Alasan lainnya"
	
	case lihatRiwayatTransaksi = "Lihat Riwayat Transaksi"
	case tambahEmailDesc = "Masukan satu alamat email yang akan kamu gunakan sebagai email utama toko"
    case inputEmail = "Input Email"
	case nameGroup = "Nama Grup"
	case createGroup = "Buat Grup"
	case addMemberChat = "Tambah Anggota"
	case memberGroup = "Anggota Grup"
	case startChatting = "Mulai Percakapan"
	case myProduct = "My Product"
	case image = "Image"
	case pleaseWait = "Mohon Tunggu"
    case bukaBlocker = "Buka Blockir"
    case userAlreadyBlock = "User telah diblock"
	case blockir = "Blokir"
    case block = "Block"
	case givePermission = "Izinkan"
	case textAskingPermissionChat = "ingin mengirimi anda pesan, apakah kamu mengizinkan percakapan ini?"
	case typeYourChat = "Tulis pesan.."
	case mulaiChat = "Mulai Chat"
	case mulatChatDengan = "Mulai Chat dengan"
	case yes = "Ya"
	case no = "Tidak"
	case dontHaveGroup = "Belum ada group"
	case createGroupWithYourFriends = "Kamu bisa membuat group \ndengan teman-temanmu"
	case minimum2MemberChat =  "Setidaknya kamu harus memlilih min 2 anggota, dan max 10 anggota untuk membuat grup"
	case sharedTo = "Share To"
	case emptyWord = "empty"
	case direct = "Direct"
	case group = "Grup"
	case message = "Message"
	case sendFeed = "mengirimkan feed"
	case notFoundNameProduct =  "tidak dapat ditemukan, masukan kata kunci yang lain."
	case addAddressCourier = "Tambahkan alamat pengiriman untuk mulai jualan di KipasKipas"
	case findWhatYouwant = "Temukan yang kamu mau.."
	case addAddressSender = "Tambah Alamat Kirim +"
    case notFoundChat = "Belum ada percakapan"
    case choosePeopleToChat = "Pilih orang untuk memulai percakapan"
	case findChat = "Temukan Percakapan"
	case alamatBerhasilDirubah = "Alamat Berhasil Dirubah"
	case alamatBerhasilDirubahDesc = "Apa kamu ingin memilih kembali kurir untuk pengiriman pesanan?"
	case pilihUlangKurir = "Pilih Ulang Kurir"
	case lewati = "Lewati"
	
	case yourAreNotFollowChannel = "Kamu belum follow channel apapun"
	case seeAll = "See All"
	
	case weightInfo = "Informasi Berat"
	case weightTermCondition = "Harap teliti saat memasukan informasi berat sesuai dengan  barang sebenarnya. Apabila terdapat ketidak sesuaian berat barang dan terjadi penyesuaian harga, nominal penyesuaian akan ditangguhkan kepada seller. Pastikan berat dalam satuan kilogram."
	case courierNotAvailableDesc = "Maaf, kurir kami tidak bisa menjangkau alamat yang kamu gunakan saat ini, ganti dengan alamat lain yang dapat dijangkau oleh kurir kami. "
	
	case kurirTidakTersedia = "Kurir tidak tersedia"
	case kurirTidakTersediaDesc = "Alamat yang kamu gunakan tidak bisa dijangkau kurir kami, gunakan alamat lain untuk melanjutkan transaksi pembelian."
	case gunakanAlamatLain = "Gunakan Alamat Lain"

    case penyesuaianHarga = "Penyesuaian Harga"
    case penyesuaianOngkir = "Penyesuaian Ongkir"

	case plusProduk = "+ Produk"
    
    case bannedProduct = "Banned Product"

    case syaratKetentuanCheckbox = "Saya setuju dengan Syarat & Ketentuan"
    case syaratKetentuan = "Syarat & Ketentuan"
    case kebijakanPrivasi = "Kebijakan Privasi"
    
    case kipasKipasTermsConditionsUrl = "https://kipaskipas.com/syarat-dan-ketentuan-kipaskipas/"
    case kipasKipasPrivacyPolicyUrl = "https://kipaskipas.com/kebijakan-privasi-kipaskipas/"
	
	case otherSocmed = "Other Social Media"
	
	case inputLinkHere = "Input link here"
    
    case lihatSumberBerita = "Lihat Sumber Berita"

    case simpanPerubahan = "Simpan Perubahan"
    case menunggu = "Menunggu"
    case pembayaranExpired = "Pembayaran Expired"
    case sedangDiproses = "Sedang Diproses"
    case sedangDiantar = "Sedang Diantar"
    case pesananSampai = "Pesanan Sampai"
    case pesananSelesai = "Pesanan Selesai"
    case dibatalkan = "Dibatalkan"
    case dikembalikan = "Dikembalikan"
    case produkDibanned = "Produk Dibanned"
    case tikTok = "TikTok"
    case tikTokAlertDesc = "Kamu hanya bisa mengunggah 1 media beserta 150 karakter, jika kamu melanjutkan untuk memilih channel  \"Cleeps 🇮🇩 \", media dan caption akan terhapus sesuai dengan batas karakter."
    case lanjutkan = "Lanjutkan"
    
    case minimalBerat01 = "Minimal berat 0,1 Kg"
    case maksimalBerat50 = "Maksimal berat 50 Kg"
	
	case rekeningTujuan = "Rekening Tujuan"
	case rekeningSaya = "Rekening Saya"
    
    case tokoKamuBelumSiap = "Toko kamu belum siap.."
    case tokoBelumSiapDesc = "Tambahkan alamat pengiriman & alamat email untuk agar kamu bisa menggunakan dua fitur posting ini"
    case tokoProfileShop = "Profile > Shop"
    case fotoVideoMinimalSatu = "Foto atau Video minimal satu"
    
    case media = "Media"
    case close = "Close"
    case hapusFoto = "Hapus Foto"
    case subtitleHapusFoto = "Anda yakin untuk menghapus foto ini?"
    case sudahDiterima = "Sudah diterima"
    case alamatPengirimanPesanan = "Alamat pengiriman pesanan"
    case emptyAddressPlaceholder = "Tambahkan alamat pengiriman pesanan untuk mulai berjualan di KipasKipas"
    case emptyShopAddressPlaceholder = "Kamu belum \n menambahkan alamat"
    
    case emptyString = ""
    case balenceEmpty = "Account ini belum register fitur saldo"
    case somethingWrong = "Opsss, something wrong\n please try again.."
    case emptyNotifSocial = "Belum ada aktivitas sosial media\ndi akun kamu"
    case emptyNotifTrans = "Kamu belum melakukan \ntransaksi apapun"
    
    case tokenInvalid = "Your authentication token is invali or has expired, please to login again."
    case sesiKedaluwarsa = "Sesi anda berakhir silahkan login kembali."
    case userFreezeDesc = "Kamu sudah beberapa kali mencoba memasukan password / username yang tidak sesuai, untuk keamanan akun, kami akan menghentikan aktifitas login ke KipasKipas pada perangkat ini selama 10 menit."
    case userFreezeTitle = "Aktifitas login dihentikan sementara"
    case logoutFailed = "Logout failed, please try again!"
    case successDeleteAccount = "Akun kamu telah berhasil dihapus dari aplikasi Kipaskipas."
    case deleteAccountAlert = "Apakah kamu yakin ingin menghapus akun kamu di aplikasi Kipaskipas?"
    case fillPasswordFirst = "Silahkan masukan password terlebih dahulu!"
    case emptyChannels = "Oppss, channel tidak di temukan.."
    case emptyMyChannels = "Belum ada channel yang kamu ikuti"
    case seeAllChannel = "Lihat semua channel"
    case successDeleteProduct = "Produk berhasil dihapus"
    case birthDate = "Birth Date"
    case pria = "Pria"
    case wanita = "Wanita"
    case noGender = "Tidak Ingin Diketahui"
    case imPerson = "Saya adalah seorang"
    case profileInfo = "Profile Info"
    case reportedTitle = "Terimakasih atas laporan yang kamu berikan"
    case reportedDescription = "Laporan kamu sangat membantu dalam menciptakan sosial media yang positif."
    case deleteComment = "Hapus Komentar"
    case deleteCommentAsk = "Yakin ingin menghapus komentar ini?"
    
    case reviewAll = "Semua Ulasan"
    case reviewPhotoAll = "Semua Foto Ulasan"
    case reviewSuccessAddTitle = "Terimakasih atas ulasan yang kamu berikan"
    case reviewSuccessAddDesc = "Ulasan kamu dapat membantu pengguna lain dalam memilih barang dengan kualitas terbaik"
    case pilihPengiriman = "Pilih Pengiriman"
    case usernameAlreadyExists = "Username sudah digunakan oleh pengguna lain, silahkan gunakan kombinasi username lain untuk mendaftar."
    case emailAlreadyExists = "Email sudah digunakan oleh salahsatu akun di Kipaskipas, periksa terlebih dahulu apakah kamu sudah pernah mendaftar sebelumnya."
    
    case qrCode = "QR Code"
    case qrRecogFailTitle = "Gagal mengenali Kode QR"
    case qrCodeFound = "We have found QR Code from kipas kipas, are you want open it?"
    case qrNotFound = "QR Tidak Ditemukan"
    case qrUrlNotValid = "QR tidak valid"
    case phoneNumberInvalid = "Format nomor telpon belum sesuai."
    
    case noMailAccount = "Tidak ada account Email"
    
    //MARK: Public Empty Content
    case publicEmptyContentTitle = "Konten Guest Habis"
    case publicEmptyContentDescription = "Saatnya Login untuk melihat konten menarik lainnya."
}
