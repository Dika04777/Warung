import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(const WarungApp());

class WarungApp extends StatelessWidget {
  const WarungApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Warung Simulator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.orange, useMaterial3: true),
      home: const WarungGame(),
    );
  }
}

class WarungGame extends StatefulWidget {
  const WarungGame({super.key});
  @override
  State<WarungGame> createState() => _WarungGameState();
}

class _WarungGameState extends State<WarungGame> {
  int uang = 100, sabar = 100, hari = 1, pelangganHariIni = 0, patience = 100;
  double rating = 5.0;
  bool gameOver = false, menang = false, bahanBenar = false;
  String pesan = "Selamat datang di warung!";
  String nama = "Pelanggan", dialog = "Bang, bagi Indomie dong.";
  String orderBase = "Indomie", orderMod = "tanpa mie";
  Timer? timer;
  final rnd = Random();

  final bases = ['Indomie', 'Kopi', 'Gorengan', 'Es Teh'];
  final mods = ['tanpa mie','kuah dipisah','pedas level 999','micin 5x','pakai doa','setengah matang'];
  final names = ['Budi S.Kom','Tuyul Tetangga','Pak RT','Ojol Salah Antar','Anak TikTok','Dosen Killer'];

  @override
  void initState() {
    super.initState();
    spawn();
    timer = Timer.periodic(const Duration(seconds: 2), (t) {
      if (gameOver) return;
      setState(() => patience -= 2);
      if (patience <= 0) kabur();
    });
  }

  void spawn() {
    if (gameOver) return;
    setState(() {
      nama = names[rnd.nextInt(names.length)];
      orderBase = bases[rnd.nextInt(bases.length)];
      orderMod = mods[rnd.nextInt(mods.length)];
      dialog = "Bang, pesan $orderBase $orderMod. Cepetan!";
      patience = 100;
      bahanBenar = false;
      pesan = "$nama datang!";
    });
  }

  void pilih(String b) {
    if (gameOver) return;
    setState(() {
      if (b == orderBase) { bahanBenar = true; pesan = "Bahan benar!"; }
      else {
        bahanBenar = false;
        rating = (rating - 0.5).clamp(0, 5);
        sabar = (sabar - 10).clamp(0, 100);
        pesan = "Salah! $nama marah!";
        cek();
      }
    });
  }

  void sajikan() {
    if (gameOver) return;
    bool lanjut = false;
    setState(() {
      if (bahanBenar) {
        final bayar = 15 + rnd.nextInt(20);
        uang += bayar;
        rating = (rating + 0.1).clamp(0, 5);
        pesan = "$nama bayar Rp$bayar. Kurang vibes.";
        pelangganHariIni++;
        bahanBenar = false;
        lanjut = true;
      } else {
        rating = (rating - 0.3).clamp(0, 5);
        sabar = (sabar - 5).clamp(0, 100);
        pesan = "Bukan pesanan saya, bang.";
        cek();
      }
    });
    if (lanjut) next();
  }

  void next() {
    if (pelangganHariIni >= 5) {
      hari++;
      if (hari > 7) {
        menang = true; gameOver = true;
        pesan = "MENANG! Bertahan 7 hari!";
        return;
      }
      pelangganHariIni = 0;
      pesan = "Hari $hari dimulai!";
    }
    spawn();
  }

  void sabarBtn() {
    if (gameOver) return;
    setState(() {
      sabar = (sabar + 15).clamp(0, 100);
      pesan = "Tarik napas. Sabar +15.";
    });
  }

  void usir() {
    if (gameOver) return;
    setState(() {
      rating = (rating - 0.7).clamp(0, 5);
      sabar = (sabar + 10).clamp(0, 100);
      pesan = "Kamu usir $nama. Lega!";
      pelangganHariIni++;
    });
    next();
  }

  void nangis() {
    if (gameOver) return;
    setState(() {
      sabar = (sabar + 5).clamp(0, 100);
      uang -= 5;
      pesan = "Kamu nangis. Sabar +5, uang -5.";
      cek();
    });
  }

  void kabur() {
    if (gameOver) return;
    bool lanjut = false;
    setState(() {
      rating = (rating - 0.8).clamp(0, 5);
      sabar = (sabar - 15).clamp(0, 100);
      pesan = "$nama kabur. Rating ambyar.";
      pelangganHariIni++;
      cek();
      if (!gameOver) lanjut = true;
    });
    if (lanjut) next();
  }

  void cek() {
    if (sabar <= 0) { sabar = 0; gameOver = true; pesan = "Sabar habis. Game over."; }
    else if (uang < 0) { gameOver = true; pesan = "Uang minus. Game over."; }
  }

  void reset() {
    setState(() {
      uang = 100; sabar = 100; rating = 5.0; hari = 1;
      pelangganHariIni = 0; gameOver = false; menang = false;
      pesan = "Warung buka lagi!"; spawn();
    });
  }

  @override
  void dispose() { timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Warung Simulator'), backgroundColor: Colors.orange, foregroundColor: Colors.white),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          Wrap(spacing: 8, children: [
            Chip(label: Text('Uang: $uang')),
            Chip(label: Text('Sabar: $sabar')),
            Chip(label: Text('Rating: ${rating.toStringAsFixed(1)}')),
            Chip(label: Text('Hari: $hari/7')),
          ]),
          const SizedBox(height: 12),
          Card(child: Padding(padding: const EdgeInsets.all(12), child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(nama, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text('Order: $orderBase $orderMod'),
              Text(dialog, style: const TextStyle(fontStyle: FontStyle.italic)),
              const SizedBox(height: 8),
              LinearProgressIndicator(value: patience / 100),
            ],
          ))),
          const SizedBox(height: 12),
          Text(pesan, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: bases.map((b) =>
            ElevatedButton(onPressed: () => pilih(b), child: Text(b))).toList()),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [
            ElevatedButton(onPressed: sajikan, style: ElevatedButton.styleFrom(backgroundColor: Colors.green), child: const Text('Sajikan', style: TextStyle(color: Colors.white))),
            ElevatedButton(onPressed: sabarBtn, style: ElevatedButton.styleFrom(backgroundColor: Colors.blue), child: const Text('Sabar', style: TextStyle(color: Colors.white))),
            ElevatedButton(onPressed: usir, style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('Usir', style: TextStyle(color: Colors.white))),
            ElevatedButton(onPressed: nangis, style: ElevatedButton.styleFrom(backgroundColor: Colors.grey), child: const Text('Nangis', style: TextStyle(color: Colors.white))),
          ]),
          const Spacer(),
          if (gameOver) Column(children: [
            Text(menang ? 'MENANG!' : 'GAME OVER', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            ElevatedButton(onPressed: reset, child: const Text('Main Lagi')),
          ]),
        ]),
      ),
    );
  }
}
