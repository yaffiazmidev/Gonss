//
//  TermAndConditionView.swift
//  KipasKipas
//
//  Created by Daniel Partogi on 11/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.

import UIKit
import WebKit

protocol TermAndConditionViewDelegate where Self: UIViewController {
  
  func sendDataBackToParent(_ data: Data)
}

protocol TermAndConditionViewDataSource where Self: UIViewController {
	func urlString() -> String
}

final class TermAndConditionView: UIView {
  
  weak var delegate: TermAndConditionViewDelegate?
	weak var dataSource: TermAndConditionViewDataSource?

	private var html = "<div>\n" +
		"<h1 class=\"ace-copy-paste-skip-this-tag\"><span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxuz87zdz89zez76zz81z8z68zz72zz73ziz88zz74zwumdz78zz70zz68zz74zjy5z66zz82zz70zz82zz65zg\">Syarat dan Ketentuan KipasKipas</span></h1>\n" +
		"<p>&nbsp;</p>\n" +
		"</div>\n" +
		"<div>\n" +
		"<h2 data-usually-unique-id=\"483103867907037482576354\"><span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxwekitz86zz69zz65zz76zcz74zz90zoz87zz74zvk9z74zz90zz88zz67zdcz74zyz80z4wja\">Pendahuluan</span></h2>\n" +
		"</div>\n" +
		"<ul class=\"listtype-bullet listindent1 list-bullet1\">\n" +
		"<li><span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxwekitz86zz69zz65zz76zcz74zz90zoz87zz74zvk9z74zz90zz88zz67zdcz74zyz80z4wja\">Selamat datang di platfom </span><span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxuz87zdz89zez76zz81z8z68zz72zz73ziz88zz74zwumdz78zz70zz68zz74zjy5z66zz82zz70zz82zz65zg\">KipasKipas</span><span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxwekitz86zz69zz65zz76zcz74zz90zoz87zz74zvk9z74zz90zz88zz67zdcz74zyz80z4wja\">. Dengan mendaftar dan/atau menggunakan</span><span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxuz87zdz89zez76zz81z8z68zz72zz73ziz88zz74zwumdz78zz70zz68zz74zjy5z66zz82zz70zz82zz65zg\"> KipasKipas</span> <span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxwekitz86zz69zz65zz76zcz74zz90zoz87zz74zvk9z74zz90zz88zz67zdcz74zyz80z4wja h-lparen\">(mencakup</span> <span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxuz87zdz89zez76zz81z8z68zz72zz73ziz88zz74zwumdz78zz70zz68zz74zjy5z66zz82zz70zz82zz65zg\">persada-entertainment</span><span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxwekitz86zz69zz65zz76zcz74zz90zoz87zz74zvk9z74zz90zz88zz67zdcz74zyz80z4wja\">.com, situs, aplikasi mobile, layanan, dan piranti terkait), maka Pengguna dianggap telah membaca, mengerti, memahami dan menyutujui semua isi dalam Syarat &amp; Ketentuan.&nbsp;</span></li>\n" +
		"<li><span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxwekitz86zz69zz65zz76zcz74zz90zoz87zz74zvk9z74zz90zz88zz67zdcz74zyz80z4wja\">Syarat &amp; Ketentuan ini merupakan bentuk kesepakatan yang merupakan perjanjian mengikat antara Pengguna dengan </span><span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxuz87zdz89zez76zz81z8z68zz72zz73ziz88zz74zwumdz78zz70zz68zz74zjy5z66zz82zz70zz82zz65zg\">KipasKipas</span><span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxwekitz86zz69zz65zz76zcz74zz90zoz87zz74zvk9z74zz90zz88zz67zdcz74zyz80z4wja\">. Pengguna secara sadar dan sukarela menyetujui Syarat &amp; Ketentuan ini untuk menggunakan layanan di platform </span><span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxuz87zdz89zez76zz81z8z68zz72zz73ziz88zz74zwumdz78zz70zz68zz74zjy5z66zz82zz70zz82zz65zg\">KipasKipas</span><span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxwekitz86zz69zz65zz76zcz74zz90zoz87zz74zvk9z74zz90zz88zz67zdcz74zyz80z4wja\">.</span></li>\n" +
		"</ul>\n" +
		"<div>\n" +
		"<h2 data-usually-unique-id=\"483103867907037482576354\">&nbsp;</h2>\n" +
		"</div>\n" +
		"<div>\n" +
		"<h2 data-usually-unique-id=\"298261526559205372783905\"><span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxwekitz86zz69zz65zz76zcz74zz90zoz87zz74zvk9z74zz90zz88zz67zdcz74zyz80z4wja\">Modifikasi Platform dan Syarat &amp; Ketentuan</span></h2>\n" +
		"</div>\n" +
		"<ul class=\"listtype-bullet listindent1 list-bullet1\">\n" +
		"<li><span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxuz87zdz89zez76zz81z8z68zz72zz73ziz88zz74zwumdz78zz70zz68zz74zjy5z66zz82zz70zz82zz65zg\">KipasKipas </span><span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxwekitz86zz69zz65zz76zcz74zz90zoz87zz74zvk9z74zz90zz88zz67zdcz74zyz80z4wja\">berhak untuk mengubah, memodifikasi, memperbarui atau menghentikan syarat, ketentuan, dan pemberitahuan yang ditawarkan melalui platform </span><span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxuz87zdz89zez76zz81z8z68zz72zz73ziz88zz74zwumdz78zz70zz68zz74zjy5z66zz82zz70zz82zz65zg\">KipasKipas</span><span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxwekitz86zz69zz65zz76zcz74zz90zoz87zz74zvk9z74zz90zz88zz67zdcz74zyz80z4wja\"> kapan saja dan dari waktu ke waktu tanpa pemberitahuan atau kewajiban lebih lanjut kepada Pengguna kecuali sebagaimana dapat diberikan di dalamnya.&nbsp;</span></li>\n" +
		"<li><span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxwekitz86zz69zz65zz76zcz74zz90zoz87zz74zvk9z74zz90zz88zz67zdcz74zyz80z4wja\">Dengan terus menggunakan platform </span><span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxuz87zdz89zez76zz81z8z68zz72zz73ziz88zz74zwumdz78zz70zz68zz74zjy5z66zz82zz70zz82zz65zg\">KipasKipas </span><span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxwekitz86zz69zz65zz76zcz74zz90zoz87zz74zvk9z74zz90zz88zz67zdcz74zyz80z4wja\">setelah modifikasi, perubahan, atau pembaruan tersebut, Pengguna setuju untuk terikat oleh modifikasi, perubahan, atau pembaruan tersebut.</span></li>\n" +
		"</ul>\n" +
		"<div>\n" +
		"<h2 data-usually-unique-id=\"298261526559205372783905\">&nbsp;</h2>\n" +
		"</div>\n" +
		"<div>\n" +
		"<h2 data-usually-unique-id=\"582888031549635571449923\"><span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxwekitz86zz69zz65zz76zcz74zz90zoz87zz74zvk9z74zz90zz88zz67zdcz74zyz80z4wja\">Kebijakan Pemesanan Jasa </span><span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxuz87zdz89zez76zz81z8z68zz72zz73ziz88zz74zwumdz78zz70zz68zz74zjy5z66zz82zz70zz82zz65zg\">KipasKipas</span></h2>\n" +
		"</div>\n" +
		"<ul class=\"listtype-bullet listindent1 list-bullet1\">\n" +
		"<li><span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxuz87zdz89zez76zz81z8z68zz72zz73ziz88zz74zwumdz78zz70zz68zz74zjy5z66zz82zz70zz82zz65zg\">KipasKipas </span><span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxwekitz86zz69zz65zz76zcz74zz90zoz87zz74zvk9z74zz90zz88zz67zdcz74zyz80z4wja\">berhak menolak dan membatalkan proses transaksi ke Pembeli, termasuk apabila harga maupun barang sudah tidak tersedia kembali dari Penjual.</span></li>\n" +
		"<li><span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxwekitz86zz69zz65zz76zcz74zz90zoz87zz74zvk9z74zz90zz88zz67zdcz74zyz80z4wja\">Persediaan barang, waktu pengiriman, kondisi barang dan harga tergantung dari Penjual tersebut. </span><span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxuz87zdz89zez76zz81z8z68zz72zz73ziz88zz74zwumdz78zz70zz68zz74zjy5z66zz82zz70zz82zz65zg\">KipasKipas </span><span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxwekitz86zz69zz65zz76zcz74zz90zoz87zz74zvk9z74zz90zz88zz67zdcz74zyz80z4wja\">hanya sebagai wadah yang mempertemukan antara Penjual dan Pembeli dan mengatur agar transaksi berjalan dengan lancar.</span></li>\n" +
		"</ul>\n" +
		"<div>\n" +
		"<h2 data-usually-unique-id=\"582888031549635571449923\">&nbsp;</h2>\n" +
		"</div>\n" +
		"<div>\n" +
		"<h2 data-usually-unique-id=\"722785068217908929562450\"><span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxwekitz86zz69zz65zz76zcz74zz90zoz87zz74zvk9z74zz90zz88zz67zdcz74zyz80z4wja\">Hak Cipta</span></h2>\n" +
		"</div>\n" +
		"<ul class=\"listtype-bullet listindent1 list-bullet1\">\n" +
		"<li><span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxwekitz86zz69zz65zz76zcz74zz90zoz87zz74zvk9z74zz90zz88zz67zdcz74zyz80z4wja\">Platform </span><span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxuz87zdz89zez76zz81z8z68zz72zz73ziz88zz74zwumdz78zz70zz68zz74zjy5z66zz82zz70zz82zz65zg\">KipasKipas </span><span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxwekitz86zz69zz65zz76zcz74zz90zoz87zz74zvk9z74zz90zz88zz67zdcz74zyz80z4wja\">dimiliki dan dioperasikan oleh </span><span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxuz87zdz89zez76zz81z8z68zz72zz73ziz88zz74zwumdz78zz70zz68zz74zjy5z66zz82zz70zz82zz65zg\">KipasKipas</span><span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxwekitz86zz69zz65zz76zcz74zz90zoz87zz74zvk9z74zz90zz88zz67zdcz74zyz80z4wja\">. Kecuali ditentukan lain, semua materi di platform </span><span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxuz87zdz89zez76zz81z8z68zz72zz73ziz88zz74zwumdz78zz70zz68zz74zjy5z66zz82zz70zz82zz65zg\">KipasKipas</span><span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxwekitz86zz69zz65zz76zcz74zz90zoz87zz74zvk9z74zz90zz88zz67zdcz74zyz80z4wja\">, merek dagang, merek layanan, logo adalah milik </span><span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxuz87zdz89zez76zz81z8z68zz72zz73ziz88zz74zwumdz78zz70zz68zz74zjy5z66zz82zz70zz82zz65zg\">KipasKipas </span><span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxwekitz86zz69zz65zz76zcz74zz90zoz87zz74zvk9z74zz90zz88zz67zdcz74zyz80z4wja\">dan dilindungi oleh undang-undang hak cipta Indonesia dan, di seluruh dunia oleh undang-undang hak cipta yang berlaku.&nbsp;</span></li>\n" +
		"<li><span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxwekitz86zz69zz65zz76zcz74zz90zoz87zz74zvk9z74zz90zz88zz67zdcz74zyz80z4wja\">Tidak ada materi yang diterbitkan oleh </span><span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxuz87zdz89zez76zz81z8z68zz72zz73ziz88zz74zwumdz78zz70zz68zz74zjy5z66zz82zz70zz82zz65zg\">KipasKipas </span><span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxwekitz86zz69zz65zz76zcz74zz90zoz87zz74zvk9z74zz90zz88zz67zdcz74zyz80z4wja\">di platform ini, secara keseluruhan atau sebagian, dapat disalin, direproduksi, dimodifikasi, diterbitkan ulang, diunggah, diposting, dikirim, atau didistribusikan dalam bentuk apa pun atau dengan cara apa pun tanpa izin tertulis dari </span><span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxuz87zdz89zez76zz81z8z68zz72zz73ziz88zz74zwumdz78zz70zz68zz74zjy5z66zz82zz70zz82zz65zg\">KipasKipas</span><span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxwekitz86zz69zz65zz76zcz74zz90zoz87zz74zvk9z74zz90zz88zz67zdcz74zyz80z4wja\">.</span></li>\n" +
		"</ul>\n" +
		"<div>\n" +
		"<h2 data-usually-unique-id=\"969803529543142608507060\">&nbsp;</h2>\n" +
		"<h2 data-usually-unique-id=\"969803529543142608507060\"><span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxwekitz86zz69zz65zz76zcz74zz90zoz87zz74zvk9z74zz90zz88zz67zdcz74zyz80z4wja\">Harga</span></h2>\n" +
		"</div>\n" +
		"<ul class=\"listtype-bullet listindent1 list-bullet1\">\n" +
		"<li><span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxwekitz86zz69zz65zz76zcz74zz90zoz87zz74zvk9z74zz90zz88zz67zdcz74zyz80z4wja\">Seluruh biaya yang tertera pada platform </span><span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxuz87zdz89zez76zz81z8z68zz72zz73ziz88zz74zwumdz78zz70zz68zz74zjy5z66zz82zz70zz82zz65zg\">KipasKipas </span><span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxwekitz86zz69zz65zz76zcz74zz90zoz87zz74zvk9z74zz90zz88zz67zdcz74zyz80z4wja\">menggunakan mata uang Rupiah.</span></li>\n" +
		"</ul>\n" +
		"<div>\n" +
		"<h2 data-usually-unique-id=\"969803529543142608507060\">&nbsp;</h2>\n" +
		"</div>\n" +
		"<div>\n" +
		"<h2 data-usually-unique-id=\"328290278364224433031274\"><span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxwekitz86zz69zz65zz76zcz74zz90zoz87zz74zvk9z74zz90zz88zz67zdcz74zyz80z4wja\">Penghitungan Harga Pengiriman</span></h2>\n" +
		"</div>\n" +
		"<ul class=\"listtype-bullet listindent1 list-bullet1\">\n" +
		"<li><span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxwekitz86zz69zz65zz76zcz74zz90zoz87zz74zvk9z74zz90zz88zz67zdcz74zyz80z4wja\">Perhitungan berat barang minimum adalah 1 Kg. Berat barang dihitung berdasarkan berat barang atau volume / dimensi</span> <span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxwekitz86zz69zz65zz76zcz74zz90zoz87zz74zvk9z74zz90zz88zz67zdcz74zyz80z4wja h-lparen\">(P&times;L&times;T/6.000)</span><span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxwekitz86zz69zz65zz76zcz74zz90zoz87zz74zvk9z74zz90zz88zz67zdcz74zyz80z4wja\"> barang, yang kemudian akan dipilih berdasarkan mana yang lebih berat.</span></li>\n" +
		"</ul>\n" +
		"<div>\n" +
		"<h2 data-usually-unique-id=\"669398879089166459213799\">&nbsp;</h2>\n" +
		"</div>\n" +
		"<div>\n" +
		"<h2 data-usually-unique-id=\"733521878226930184747524\"><span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxwekitz86zz69zz65zz76zcz74zz90zoz87zz74zvk9z74zz90zz88zz67zdcz74zyz80z4wja\">Barang yang Dilarang</span></h2>\n" +
		"</div>\n" +
		"<div>\n" +
		"<h2 data-usually-unique-id=\"733521878226930184747524\"><span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxwekitz86zz69zz65zz76zcz74zz90zoz87zz74zvk9z74zz90zz88zz67zdcz74zyz80z4wja\">Barang yang dilarang untuk diperjualbelikan di dalam platform </span><span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxuz87zdz89zez76zz81z8z68zz72zz73ziz88zz74zwumdz78zz70zz68zz74zjy5z66zz82zz70zz82zz65zg\">KipasKipas </span><span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxwekitz86zz69zz65zz76zcz74zz90zoz87zz74zvk9z74zz90zz88zz67zdcz74zyz80z4wja\">adalah:</span></h2>\n" +
		"</div>\n" +
		"<ul class=\"listtype-bullet listindent1 list-bullet1\">\n" +
		"<li><span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxwekitz86zz69zz65zz76zcz74zz90zoz87zz74zvk9z74zz90zz88zz67zdcz74zyz80z4wja\">Barang antik yang bernilai tinggi</span></li>\n" +
		"<li><span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxwekitz86zz69zz65zz76zcz74zz90zoz87zz74zvk9z74zz90zz88zz67zdcz74zyz80z4wja\">Apapun yang mudah terbakar, dengan titik nyala dari 140 derajat Fahrenheit, atau lebih kecil</span></li>\n" +
		"<li><span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxwekitz86zz69zz65zz76zcz74zz90zoz87zz74zvk9z74zz90zz88zz67zdcz74zyz80z4wja\">Suku cadang dengan cairan di dalamnya</span></li>\n" +
		"<li><span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxwekitz86zz69zz65zz76zcz74zz90zoz87zz74zvk9z74zz90zz88zz67zdcz74zyz80z4wja\">Benda seni berharga</span></li>\n" +
		"<li><span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxwekitz86zz69zz65zz76zcz74zz90zoz87zz74zvk9z74zz90zz88zz67zdcz74zyz80z4wja\">Perhiasan berharga</span></li>\n" +
		"<li><span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxwekitz86zz69zz65zz76zcz74zz90zoz87zz74zvk9z74zz90zz88zz67zdcz74zyz80z4wja\">Bulu</span></li>\n" +
		"<li><span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxwekitz86zz69zz65zz76zcz74zz90zoz87zz74zvk9z74zz90zz88zz67zdcz74zyz80z4wja\">Barang berbau pornografi</span></li>\n" +
		"<li><span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxwekitz86zz69zz65zz76zcz74zz90zoz87zz74zvk9z74zz90zz88zz67zdcz74zyz80z4wja\">Logam mulia, dengan pengecualian dari perhiasan berharga</span></li>\n" +
		"<li><span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxwekitz86zz69zz65zz76zcz74zz90zoz87zz74zvk9z74zz90zz88zz67zdcz74zyz80z4wja\">Senjata dan aksesoris senjata.</span></li>\n" +
		"</ul>\n" +
		"<div>\n" +
		"<h2 data-usually-unique-id=\"733521878226930184747524\">&nbsp;</h2>\n" +
		"</div>\n" +
		"<div>\n" +
		"<h2 data-usually-unique-id=\"333754572688624088159798\"><span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxwekitz86zz69zz65zz76zcz74zz90zoz87zz74zvk9z74zz90zz88zz67zdcz74zyz80z4wja\">Barang yang Dibatasi</span></h2>\n" +
		"</div>\n" +
		"<div>\n" +
		"<h2 data-usually-unique-id=\"333754572688624088159798\"><span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxwekitz86zz69zz65zz76zcz74zz90zoz87zz74zvk9z74zz90zz88zz67zdcz74zyz80z4wja\">Berikut adalah daftar barang yang dibatasi:</span></h2>\n" +
		"</div>\n" +
		"<ul class=\"listtype-bullet listindent1 list-bullet1\">\n" +
		"<li><span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxwekitz86zz69zz65zz76zcz74zz90zoz87zz74zvk9z74zz90zz88zz67zdcz74zyz80z4wja\">Minuman Beralkohol</span></li>\n" +
		"<li><span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxwekitz86zz69zz65zz76zcz74zz90zoz87zz74zvk9z74zz90zz88zz67zdcz74zyz80z4wja\">Kulit hewan</span></li>\n" +
		"<li><span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxwekitz86zz69zz65zz76zcz74zz90zoz87zz74zvk9z74zz90zz88zz67zdcz74zyz80z4wja\">Obat-obatan: tanpa resep dokter</span></li>\n" +
		"<li><span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxwekitz86zz69zz65zz76zcz74zz90zoz87zz74zvk9z74zz90zz88zz67zdcz74zyz80z4wja\">Obat-obatan: resep dokter</span></li>\n" +
		"</ul>\n" +
		"<div>\n" +
		"<h2 data-usually-unique-id=\"333754572688624088159798\">&nbsp;</h2>\n" +
		"</div>\n" +
		"<div>\n" +
		"<h2 data-usually-unique-id=\"131352752345534008310761\"><span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxwekitz86zz69zz65zz76zcz74zz90zoz87zz74zvk9z74zz90zz88zz67zdcz74zyz80z4wja\">Kebijakan Pengembalian Barang</span> <span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxwekitz86zz69zz65zz76zcz74zz90zoz87zz74zvk9z74zz90zz88zz67zdcz74zyz80z4wja h-lparen\">(Retur),</span><span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxwekitz86zz69zz65zz76zcz74zz90zoz87zz74zvk9z74zz90zz88zz67zdcz74zyz80z4wja\"> Pengembalian Dana</span> <span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxwekitz86zz69zz65zz76zcz74zz90zoz87zz74zvk9z74zz90zz88zz67zdcz74zyz80z4wja h-lparen\">(Refund)</span><span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxwekitz86zz69zz65zz76zcz74zz90zoz87zz74zvk9z74zz90zz88zz67zdcz74zyz80z4wja\"> dan Pembatalan</span> <span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxwekitz86zz69zz65zz76zcz74zz90zoz87zz74zvk9z74zz90zz88zz67zdcz74zyz80z4wja h-lparen\">(Cancellation)</span></h2>\n" +
		"</div>\n" +
		"<ul class=\"listtype-bullet listindent1 list-bullet1\">\n" +
		"<li><span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxwekitz86zz69zz65zz76zcz74zz90zoz87zz74zvk9z74zz90zz88zz67zdcz74zyz80z4wja\">Retur berlaku apabila barang yang di terima dalam keadaan rusak/cacat/aksesoris tidak lengkap. Batas waktu maksimal 1x24 jam untuk retur.</span></li>\n" +
		"<li><span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxwekitz86zz69zz65zz76zcz74zz90zoz87zz74zvk9z74zz90zz88zz67zdcz74zyz80z4wja\">Refund berlaku apabila barang yang telah dibeli dan dibayar tidak tersedia dan akan dikembalikan dalam bentuk tunai.</span></li>\n" +
		"<li><span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxwekitz86zz69zz65zz76zcz74zz90zoz87zz74zvk9z74zz90zz88zz67zdcz74zyz80z4wja\">Refund hanya dapat diajukan jika Penjual tidak merespon pesanan dalam waktu 1&times;24 jam terhitung sejak pembayaran diverifikasi.</span></li>\n" +
		"<li><span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxwekitz86zz69zz65zz76zcz74zz90zoz87zz74zvk9z74zz90zz88zz67zdcz74zyz80z4wja\">Estimasi lama pengembalian dana adalah 15-30 hari kerja setelah pengajuan.</span></li>\n" +
		"<li><span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxwekitz86zz69zz65zz76zcz74zz90zoz87zz74zvk9z74zz90zz88zz67zdcz74zyz80z4wja\">Barang yang sudah dibeli dan dibayar tidak dapat dibatalkan.</span></li>\n" +
		"</ul>\n" +
		"<div>\n" +
		"<h2 data-usually-unique-id=\"131352752345534008310761\">&nbsp;</h2>\n" +
		"</div>\n" +
		"<div>\n" +
		"<h2 data-usually-unique-id=\"655898642876240347312362\"><span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxwekitz86zz69zz65zz76zcz74zz90zoz87zz74zvk9z74zz90zz88zz67zdcz74zyz80z4wja\">Komunikasi Elektronik</span></h2>\n" +
		"</div>\n" +
		"<div><span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxwekitz86zz69zz65zz76zcz74zz90zoz87zz74zvk9z74zz90zz88zz67zdcz74zyz80z4wja\">Pengguna setuju bahwa </span><span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxuz87zdz89zez76zz81z8z68zz72zz73ziz88zz74zwumdz78zz70zz68zz74zjy5z66zz82zz70zz82zz65zg\">KipasKipas</span><span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxwekitz86zz69zz65zz76zcz74zz90zoz87zz74zvk9z74zz90zz88zz67zdcz74zyz80z4wja\"> dapat mengirim surat elektronik kepada Pengguna untuk tujuan memberi tahu Pengguna tentang perubahan atau penambahan pada platform </span><span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxuz87zdz89zez76zz81z8z68zz72zz73ziz88zz74zwumdz78zz70zz68zz74zjy5z66zz82zz70zz82zz65zg\">KipasKipas</span><span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxwekitz86zz69zz65zz76zcz74zz90zoz87zz74zvk9z74zz90zz88zz67zdcz74zyz80z4wja\">, tentang produk atau layanan </span><span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxuz87zdz89zez76zz81z8z68zz72zz73ziz88zz74zwumdz78zz70zz68zz74zjy5z66zz82zz70zz82zz65zg\">KipasKipas</span><span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxwekitz86zz69zz65zz76zcz74zz90zoz87zz74zvk9z74zz90zz88zz67zdcz74zyz80z4wja\">, atau untuk tujuan lain apa pun yang kami anggap perlu.</span></div>\n" +
		"<div>\n" +
		"<h2 data-usually-unique-id=\"655898642876240347312362\">&nbsp;</h2>\n" +
		"</div>\n" +
		"<div>\n" +
		"<h2 data-usually-unique-id=\"486163882782354855337674\"><span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxwekitz86zz69zz65zz76zcz74zz90zoz87zz74zvk9z74zz90zz88zz67zdcz74zyz80z4wja\">Hukum yang Berlaku</span></h2>\n" +
		"</div>\n" +
		"<div><span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxwekitz86zz69zz65zz76zcz74zz90zoz87zz74zvk9z74zz90zz88zz67zdcz74zyz80z4wja\">Syarat &amp; Ketentuan ini diatur oleh hukum yang berlaku di Indonesia.</span></div>\n" +
		"<div>&nbsp;</div>\n" +
		"<div>&nbsp;</div>\n" +
		"<div><span class=\"ace-all-bold-hthree\"><span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxuz87zdz89zez76zz81z8z68zz72zz73ziz88zz74zwumdz78zz70zz68zz74zjy5z66zz82zz70zz82zz65zg\"><strong>Layanan KipasKipas</strong></span></span></div>\n" +
		"<div><span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxuz87zdz89zez76zz81z8z68zz72zz73ziz88zz74zwumdz78zz70zz68zz74zjy5z66zz82zz70zz82zz65zg\">Kami setuju untuk menyediakan Layanan KipasKipas kepada Anda. Layanan ini meliputi semua produk, fitur, aplikasi, layanan, teknologi, dan perangkat lunak KipasKipas yang kami sediakan untuk melaksanakan misi KipasKipas: Mendekatkan Anda dengan orang-orang atau hal-hal yang Anda sukai. Layanan ini terdiri dari sejumlah aspek berikut</span> <span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxuz87zdz89zez76zz81z8z68zz72zz73ziz88zz74zwumdz78zz70zz68zz74zjy5z66zz82zz70zz82zz65zg h-lparen\">(Layanan):</span></div>\n" +
		"<ul class=\"listtype-bullet listindent1 list-bullet1\">\n" +
		"<li><span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxuz87zdz89zez76zz81z8z68zz72zz73ziz88zz74zwumdz78zz70zz68zz74zjy5z66zz82zz70zz82zz65zg\">Menawarkan peluang yang dipersonalisasikan untuk membuat, menjalin hubungan, berkomunikasi, menemukan, dan membagikan.</span></li>\n" +
		"<li><span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxuz87zdz89zez76zz81z8z68zz72zz73ziz88zz74zwumdz78zz70zz68zz74zjy5z66zz82zz70zz82zz65zg\">Setiap orang berbeda antara satu dengan yang lain. Kami ingin mempererat hubungan yang Anda miliki melalui berbagi pengalaman yang berarti bagi Anda. Oleh karena itu, kami membangun sistem yang mencoba untuk memahami orang-orang dan hal-hal yang penting bagi Anda dan orang lain, dan menggunakan informasi itu untuk membantu Anda membuat, menemukan, berpartisipasi, dan membagikan pengalaman-pengalaman yang berarti bagi Anda. Bagian dari upaya tersebut adalah dengan menyorot konten, fitur, promo, dan akun yang mungkin menarik bagi Anda, dan memberi banyak cara kepada Anda untuk menikmati KipasKipas berdasarkan hal-hal yang Anda dan orang lain lakukan di dalam maupun di luar KipasKipas.</span></li>\n" +
		"<li><span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxuz87zdz89zez76zz81z8z68zz72zz73ziz88zz74zwumdz78zz70zz68zz74zjy5z66zz82zz70zz82zz65zg\">Mendorong terciptanya lingkungan yang bersifat positif, inklusif, dan aman.</span></li>\n" +
		"<li><span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxuz87zdz89zez76zz81z8z68zz72zz73ziz88zz74zwumdz78zz70zz68zz74zjy5z66zz82zz70zz82zz65zg\">Kami mengembangkan dan menggunakan alat dan menawarkan sumber daya kepada para anggota komunitas kami yang dapat membantu membuat pengalaman mereka menjadi positif dan terbuka bagi semuanya, termasuk saat kami merasa bahwa mereka mungkin memerlukan bantuan. Kami juga memiliki tim dan sistem yang berfungsi untuk menangkal penyalahgunaan dan pelanggaran Ketentuan dan kebijakan kami, dan menangkal perilaku yang merugikan dan menyesatkan. Kami menggunakan semua informasi yang kami miliki, termasuk informasi Anda, demi menjaga agar platform kami tetap aman.&nbsp;</span></li>\n" +
		"<li><span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxuz87zdz89zez76zz81z8z68zz72zz73ziz88zz74zwumdz78zz70zz68zz74zjy5z66zz82zz70zz82zz65zg\">Menjalin hubungan Anda dengan merek, produk, dan layanan melalui cara yang berarti bagi Anda.</span></li>\n" +
		"<li><span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxuz87zdz89zez76zz81z8z68zz72zz73ziz88zz74zwumdz78zz70zz68zz74zjy5z66zz82zz70zz82zz65zg\">Penelitian dan inovasi.</span></li>\n" +
		"<li><span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxuz87zdz89zez76zz81z8z68zz72zz73ziz88zz74zwumdz78zz70zz68zz74zjy5z66zz82zz70zz82zz65zg\">Kami menggunakan informasi yang kami miliki untuk mempelajari Layanan kami dan berkolaborasi dalam penelitian dengan pihak-pihak lain demi menyempurnakan Layanan kami dan memberi kontribusi pada keberlangsungan komunitas kami.</span></li>\n" +
		"</ul>\n" +
		"<div>&nbsp;</div>\n" +
		"<div><span class=\"ace-all-bold-hthree\"><span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxuz87zdz89zez76zz81z8z68zz72zz73ziz88zz74zwumdz78zz70zz68zz74zjy5z66zz82zz70zz82zz65zg\"><strong>Memperbarui Ketentuan Ini</strong></span></span></div>\n" +
	"<div><span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxuz87zdz89zez76zz81z8z68zz72zz73ziz88zz74zwumdz78zz70zz68zz74zjy5z66zz82zz70zz82zz65zg\">Kami dapat mengubah Layanan dan kebijakan kami, dan kami mungkin perlu untuk membuat perubahan pada Ketentuan ini demi mencerminkan Layanan dan kebijakan kami secara akurat. Kecuali jika diwajibkan secara hukum, kami akan memberi tahu Anda</span> <span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxuz87zdz89zez76zz81z8z68zz72zz73ziz88zz74zwumdz78zz70zz68zz74zjy5z66zz82zz70zz82zz65zg h-lparen\">(seperti</span><span class=\" author-d-1gg9uz65z1iz85zgdz68zmqkz84zo2qoxuz87zdz89zez76zz81z8z68zz72zz73ziz88zz74zwumdz78zz70zz68zz74zjy5z66zz82zz70zz82zz65zg\"> misalnya, melalui Layanan kami) sebelum kami membuat perubahan pada Ketentuan ini dan memberi waktu kepada Anda untuk meninjau Ketentuan tersebut sebelum diberlakukan. Kemudian, jika Anda terus menggunakan Layanan, maka berarti Anda akan terikat dengan Ketentuan yang telah diperbarui tersebut. Jika Anda tidak setuju dengan Ketentuan yang telah diperbarui tersebut, maka Anda dapat menghapus akun Anda.</span></div>"
  
  private enum ViewTrait {
    static let leftMargin: CGFloat = 10.0
  }

	private var wkWebView = WKWebView()

	override func draw(_ rect: CGRect) {
		addSubview(wkWebView)

		wkWebView.anchor(top: safeAreaLayoutGuide.topAnchor, left: leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)

		if let source = dataSource?.urlString() {
			wkWebView.load(URLRequest(url: URL(string: source)!))
		} else {
			wkWebView.loadHTMLString(html, baseURL: nil)
		}

	}
}
