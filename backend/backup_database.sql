-- MySQL dump 10.13  Distrib 8.0.30, for Win64 (x86_64)
--
-- Host: mysql-5dfa856-sikos.l.aivencloud.com    Database: defaultdb
-- ------------------------------------------------------
-- Server version	8.4.11

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
SET @MYSQLDUMP_TEMP_LOG_BIN = @@SESSION.SQL_LOG_BIN;
SET @@SESSION.SQL_LOG_BIN= 0;

--
-- GTID state at the beginning of the backup 
--

SET @@GLOBAL.GTID_PURGED=/*!80000 '+'*/ '0ed69708-c6b6-11f1-85ba-4eb2f79c30fd:1-66,
41673baf-c891-11f1-bf9b-5ad64046c14d:1-107';

--
-- Table structure for table `booking`
--

DROP TABLE IF EXISTS `booking`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `booking` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int unsigned NOT NULL,
  `kamar_id` int unsigned NOT NULL,
  `tgl_mulai` date NOT NULL,
  `durasi_bulan` tinyint unsigned NOT NULL DEFAULT '1',
  `tgl_selesai` date NOT NULL,
  `status` enum('menunggu','disetujui','ditolak','dibatalkan','selesai') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'menunggu',
  `alasan_penolakan` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_booking_user` (`user_id`,`status`),
  KEY `idx_booking_kamar` (`kamar_id`,`status`),
  CONSTRAINT `fk_booking_kamar` FOREIGN KEY (`kamar_id`) REFERENCES `kamar` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_booking_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `chk_booking_tanggal` CHECK ((`tgl_selesai` > `tgl_mulai`))
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `booking`
--

LOCK TABLES `booking` WRITE;
/*!40000 ALTER TABLE `booking` DISABLE KEYS */;
INSERT INTO `booking` VALUES (1,1,1,'2026-10-17',6,'2027-04-17','disetujui',NULL,'2026-10-17 01:06:20','2026-10-17 01:06:20');
/*!40000 ALTER TABLE `booking` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bukti_pembayaran`
--

DROP TABLE IF EXISTS `bukti_pembayaran`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bukti_pembayaran` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `tagihan_id` int unsigned NOT NULL,
  `path` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `catatan_penolakan` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_bukti_tagihan` (`tagihan_id`),
  CONSTRAINT `fk_bukti_tagihan` FOREIGN KEY (`tagihan_id`) REFERENCES `tagihan` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bukti_pembayaran`
--

LOCK TABLES `bukti_pembayaran` WRITE;
/*!40000 ALTER TABLE `bukti_pembayaran` DISABLE KEYS */;
/*!40000 ALTER TABLE `bukti_pembayaran` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `fasilitas`
--

DROP TABLE IF EXISTS `fasilitas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `fasilitas` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `nama` varchar(60) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_fasilitas_nama` (`nama`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `fasilitas`
--

LOCK TABLES `fasilitas` WRITE;
/*!40000 ALTER TABLE `fasilitas` DISABLE KEYS */;
INSERT INTO `fasilitas` VALUES (2,'AC'),(7,'Dapur bersama'),(3,'Kamar mandi dalam'),(4,'Kasur'),(9,'Laundry'),(5,'Lemari'),(10,'Listrik termasuk'),(6,'Meja belajar'),(8,'Parkir motor'),(1,'WiFi');
/*!40000 ALTER TABLE `fasilitas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `favorit`
--

DROP TABLE IF EXISTS `favorit`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `favorit` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int unsigned NOT NULL,
  `kos_id` int unsigned NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_favorit` (`user_id`,`kos_id`),
  KEY `fk_favorit_kos` (`kos_id`),
  CONSTRAINT `fk_favorit_kos` FOREIGN KEY (`kos_id`) REFERENCES `kos` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_favorit_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `favorit`
--

LOCK TABLES `favorit` WRITE;
/*!40000 ALTER TABLE `favorit` DISABLE KEYS */;
/*!40000 ALTER TABLE `favorit` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `kamar`
--

DROP TABLE IF EXISTS `kamar`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `kamar` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `kos_id` int unsigned NOT NULL,
  `nomor` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  `harga` int unsigned NOT NULL,
  `tersedia` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_kamar_nomor` (`kos_id`,`nomor`),
  KEY `idx_kamar_harga` (`harga`),
  CONSTRAINT `fk_kamar_kos` FOREIGN KEY (`kos_id`) REFERENCES `kos` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `kamar`
--

LOCK TABLES `kamar` WRITE;
/*!40000 ALTER TABLE `kamar` DISABLE KEYS */;
INSERT INTO `kamar` VALUES (1,1,'A1',850000,1),(2,1,'A2',850000,0),(3,1,'A3',900000,1),(4,2,'101',1000000,1),(5,2,'102',1000000,1),(6,2,'103',1200000,0),(7,3,'K1',650000,1),(8,3,'K2',650000,1),(9,3,'K3',700000,0),(10,4,'D1',750000,1),(11,4,'D2',750000,1),(12,4,'D3',800000,1),(13,4,'D4',800000,0);
/*!40000 ALTER TABLE `kamar` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `komplain`
--

DROP TABLE IF EXISTS `komplain`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `komplain` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int unsigned NOT NULL,
  `booking_id` int unsigned NOT NULL,
  `kategori` enum('listrik','air','furnitur','kebersihan','lainnya') COLLATE utf8mb4_unicode_ci NOT NULL,
  `deskripsi` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` enum('diterima','diproses','selesai') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'diterima',
  `dikonfirmasi` tinyint(1) NOT NULL DEFAULT '0',
  `tgl_konfirmasi` datetime DEFAULT NULL,
  `rating_penanganan` tinyint unsigned DEFAULT NULL,
  `komentar_penanganan` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_komplain_user` (`user_id`,`status`),
  KEY `idx_komplain_booking` (`booking_id`),
  CONSTRAINT `fk_komplain_booking` FOREIGN KEY (`booking_id`) REFERENCES `booking` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_komplain_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `chk_komplain_rating` CHECK (((`rating_penanganan` is null) or (`rating_penanganan` between 1 and 5)))
) ENGINE=InnoDB AUTO_INCREMENT=28 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `komplain`
--

LOCK TABLES `komplain` WRITE;
/*!40000 ALTER TABLE `komplain` DISABLE KEYS */;
INSERT INTO `komplain` VALUES (1,1,1,'listrik','matottttttttt','selesai',0,NULL,NULL,NULL,'2026-10-17 02:32:46','2026-10-17 02:34:28'),(2,1,1,'listrik','matottttttttt','selesai',0,NULL,NULL,NULL,'2026-10-17 02:52:48','2026-10-17 02:54:28'),(3,1,1,'listrik','AC kamar tidak dingin','selesai',0,NULL,NULL,NULL,'2026-10-17 03:09:17','2026-10-17 03:10:48'),(5,1,1,'air','air keruh guyss','selesai',0,NULL,NULL,NULL,'2026-10-17 03:39:10','2026-10-17 03:40:58'),(6,1,1,'listrik','asdasdasdasdas','selesai',0,NULL,NULL,NULL,'2026-10-17 14:47:29','2026-10-17 14:49:08'),(7,1,1,'air','asdasdasdasd','selesai',0,NULL,NULL,NULL,'2026-10-17 15:00:32','2026-10-17 15:02:08'),(8,1,1,'furnitur','meja patahhh','selesai',1,'2026-10-17 16:09:04',4,NULL,'2026-10-17 15:04:36','2026-10-17 16:09:10'),(9,1,1,'air','berminyakkkk','selesai',1,'2026-10-17 16:12:05',4,NULL,'2026-10-17 16:08:03','2026-10-17 16:12:24'),(10,1,1,'kebersihan','cxvxcvxcvxcv','selesai',0,NULL,NULL,NULL,'2026-10-17 16:10:31','2026-10-17 16:12:08'),(11,1,1,'kebersihan','asdasdasdasd','selesai',0,NULL,NULL,NULL,'2026-10-17 16:36:15','2026-10-17 16:37:48'),(12,1,1,'air','qeqweqweqweq','selesai',0,NULL,NULL,NULL,'2026-10-17 16:42:08','2026-10-17 16:43:38'),(13,1,1,'air','asdasdasdasd','selesai',0,NULL,NULL,NULL,'2026-10-17 16:46:42','2026-10-17 16:47:18'),(14,1,1,'air','asasdasdasd','selesai',0,NULL,NULL,NULL,'2026-10-17 16:52:32','2026-10-17 16:53:08'),(15,1,1,'furnitur','asdddddsas','selesai',0,NULL,NULL,NULL,'2026-10-17 16:53:43','2026-10-17 16:54:18'),(16,1,1,'kebersihan','hghfhfhghj','selesai',0,NULL,NULL,NULL,'2026-10-17 16:54:42','2026-10-17 16:55:18'),(17,1,1,'listrik','asdasdasdasd','selesai',0,NULL,NULL,NULL,'2026-10-17 16:57:47','2026-10-17 16:59:08'),(18,1,1,'lainnya','asdasdasdasd','selesai',0,NULL,NULL,NULL,'2026-10-17 17:00:21','2026-10-17 17:01:38'),(19,1,1,'furnitur','asdasdasdasda','selesai',0,NULL,NULL,NULL,'2026-10-17 17:02:15','2026-10-17 17:03:18'),(20,1,1,'furnitur','asdaaaaasddd','selesai',0,NULL,NULL,NULL,'2026-10-17 17:07:37','2026-10-17 17:08:18'),(21,1,1,'furnitur','asdasdasadsda','selesai',0,NULL,NULL,NULL,'2026-10-17 17:09:22','2026-10-17 17:09:48'),(22,1,1,'listrik','sdfasdfasd','selesai',0,NULL,NULL,NULL,'2026-10-17 17:11:38','2026-10-17 17:12:08'),(23,1,1,'kebersihan','asdasdasdasd','selesai',0,NULL,NULL,NULL,'2026-10-17 17:12:49','2026-10-17 17:13:18'),(24,1,1,'furnitur','ASSDFASDFSD','selesai',0,NULL,NULL,NULL,'2026-10-17 17:18:08','2026-10-17 17:18:38'),(25,1,1,'furnitur','asdddddddddd','selesai',0,NULL,NULL,NULL,'2026-10-17 17:21:06','2026-10-17 17:21:38'),(26,1,1,'furnitur','12123123123123','selesai',0,NULL,NULL,NULL,'2026-10-17 17:25:54','2026-10-17 17:26:16'),(27,1,1,'kebersihan','khkhkkkhkhkj','selesai',1,'2026-10-17 17:28:43',1,NULL,'2026-10-17 17:28:04','2026-10-17 17:29:07');
/*!40000 ALTER TABLE `komplain` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `komplain_foto`
--

DROP TABLE IF EXISTS `komplain_foto`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `komplain_foto` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `komplain_id` int unsigned NOT NULL,
  `path` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `urutan` tinyint unsigned NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `idx_komplain_foto` (`komplain_id`),
  CONSTRAINT `fk_komplain_foto` FOREIGN KEY (`komplain_id`) REFERENCES `komplain` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `komplain_foto`
--

LOCK TABLES `komplain_foto` WRITE;
/*!40000 ALTER TABLE `komplain_foto` DISABLE KEYS */;
INSERT INTO `komplain_foto` VALUES (1,5,'komplain/1792208351977-4381d69003db.png',1),(2,6,'komplain/1792248451269-4d5eca05f737.jpg',1),(3,7,'komplain/1792249234401-0f31c483e242.jpg',1),(4,10,'komplain/1792253433601-cea391fe27c6.jpg',1),(5,27,'komplain/1792258086626-7612ae8da57d.jpg',1);
/*!40000 ALTER TABLE `komplain_foto` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `komplain_log`
--

DROP TABLE IF EXISTS `komplain_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `komplain_log` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `komplain_id` int unsigned NOT NULL,
  `status` enum('diterima','diproses','selesai','dikonfirmasi') COLLATE utf8mb4_unicode_ci NOT NULL,
  `catatan` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_komplain_log` (`komplain_id`,`created_at`),
  CONSTRAINT `fk_komplain_log` FOREIGN KEY (`komplain_id`) REFERENCES `komplain` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=83 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `komplain_log`
--

LOCK TABLES `komplain_log` WRITE;
/*!40000 ALTER TABLE `komplain_log` DISABLE KEYS */;
INSERT INTO `komplain_log` VALUES (1,1,'diterima','Komplain diterima','2026-10-17 02:32:46'),(2,1,'diproses','Teknisi sedang dijadwalkan untuk memeriksa kamar Anda','2026-10-17 02:33:19'),(3,1,'selesai','Perbaikan telah selesai dilakukan','2026-10-17 02:34:28'),(4,2,'diterima','Komplain diterima','2026-10-17 02:52:48'),(5,2,'diproses','Teknisi sedang dijadwalkan untuk memeriksa kamar Anda','2026-10-17 02:53:18'),(6,2,'selesai','Masalah sudah ditangani oleh pemilik kos','2026-10-17 02:54:28'),(7,3,'diterima','Komplain diterima','2026-10-17 03:09:17'),(8,3,'diproses','Pemilik kos menerima laporan dan sedang menanganinya','2026-10-17 03:09:48'),(10,3,'selesai','Pekerjaan selesai, mohon periksa dan konfirmasi','2026-10-17 03:10:48'),(11,5,'diterima','Komplain diterima','2026-10-17 03:39:10'),(12,5,'diproses','Pemilik kos menerima laporan dan sedang menanganinya','2026-10-17 03:39:49'),(13,5,'selesai','Perbaikan telah selesai dilakukan','2026-10-17 03:40:58'),(14,6,'diterima','Komplain diterima','2026-10-17 14:47:29'),(15,6,'diproses','Petugas perbaikan menuju lokasi','2026-10-17 14:48:08'),(16,6,'selesai','Perbaikan telah selesai dilakukan','2026-10-17 14:49:08'),(17,7,'diterima','Komplain diterima','2026-10-17 15:00:32'),(18,7,'diproses','Teknisi sedang dijadwalkan untuk memeriksa kamar Anda','2026-10-17 15:01:08'),(19,7,'selesai','Masalah sudah ditangani oleh pemilik kos','2026-10-17 15:02:08'),(20,8,'diterima','Komplain diterima','2026-10-17 15:04:36'),(21,8,'diproses','Pemilik kos menerima laporan dan sedang menanganinya','2026-10-17 15:05:08'),(22,8,'selesai','Masalah sudah ditangani oleh pemilik kos','2026-10-17 15:06:08'),(23,9,'diterima','Komplain diterima','2026-10-17 16:08:03'),(24,9,'diproses','Pemilik kos menerima laporan dan sedang menanganinya','2026-10-17 16:08:38'),(25,8,'dikonfirmasi','Penyewa mengonfirmasi komplain selesai','2026-10-17 16:09:04'),(26,9,'selesai','Perbaikan telah selesai dilakukan','2026-10-17 16:09:38'),(27,10,'diterima','Komplain diterima','2026-10-17 16:10:32'),(28,10,'diproses','Teknisi sedang dijadwalkan untuk memeriksa kamar Anda','2026-10-17 16:11:08'),(29,9,'dikonfirmasi','Penyewa mengonfirmasi komplain selesai','2026-10-17 16:12:05'),(30,10,'selesai','Pekerjaan selesai, mohon periksa dan konfirmasi','2026-10-17 16:12:08'),(31,11,'diterima','Komplain diterima','2026-10-17 16:36:15'),(32,11,'diproses','Pemilik kos menerima laporan dan sedang menanganinya','2026-10-17 16:36:48'),(33,11,'selesai','Masalah sudah ditangani oleh pemilik kos','2026-10-17 16:37:48'),(34,12,'diterima','Komplain diterima','2026-10-17 16:42:08'),(35,12,'diproses','Teknisi sedang dijadwalkan untuk memeriksa kamar Anda','2026-10-17 16:42:38'),(36,12,'selesai','Masalah sudah ditangani oleh pemilik kos','2026-10-17 16:43:38'),(37,13,'diterima','Komplain diterima','2026-10-17 16:46:42'),(38,13,'diproses','Pemilik kos menerima laporan dan sedang menanganinya','2026-10-17 16:46:58'),(39,13,'selesai','Pekerjaan selesai, mohon periksa dan konfirmasi','2026-10-17 16:47:18'),(40,14,'diterima','Komplain diterima','2026-10-17 16:52:32'),(41,14,'diproses','Petugas perbaikan menuju lokasi','2026-10-17 16:52:48'),(42,14,'selesai','Pekerjaan selesai, mohon periksa dan konfirmasi','2026-10-17 16:53:08'),(43,15,'diterima','Komplain diterima','2026-10-17 16:53:43'),(44,15,'diproses','Pemilik kos menerima laporan dan sedang menanganinya','2026-10-17 16:53:58'),(45,15,'selesai','Masalah sudah ditangani oleh pemilik kos','2026-10-17 16:54:18'),(46,16,'diterima','Komplain diterima','2026-10-17 16:54:42'),(47,16,'diproses','Pemilik kos menerima laporan dan sedang menanganinya','2026-10-17 16:54:58'),(48,16,'selesai','Perbaikan telah selesai dilakukan','2026-10-17 16:55:18'),(49,17,'diterima','Komplain diterima','2026-10-17 16:57:47'),(50,17,'diproses','Teknisi sedang dijadwalkan untuk memeriksa kamar Anda','2026-10-17 16:58:28'),(51,17,'selesai','Pekerjaan selesai, mohon periksa dan konfirmasi','2026-10-17 16:59:08'),(52,18,'diterima','Komplain diterima','2026-10-17 17:00:21'),(53,18,'diproses','Pemilik kos menerima laporan dan sedang menanganinya','2026-10-17 17:00:58'),(54,18,'selesai','Perbaikan telah selesai dilakukan','2026-10-17 17:01:38'),(55,19,'diterima','Komplain diterima','2026-10-17 17:02:15'),(56,19,'diproses','Petugas perbaikan menuju lokasi','2026-10-17 17:02:38'),(57,19,'selesai','Pekerjaan selesai, mohon periksa dan konfirmasi','2026-10-17 17:03:18'),(58,20,'diterima','Komplain diterima','2026-10-17 17:07:37'),(59,20,'diproses','Teknisi sedang dijadwalkan untuk memeriksa kamar Anda','2026-10-17 17:07:58'),(60,20,'selesai','Perbaikan telah selesai dilakukan','2026-10-17 17:08:18'),(61,21,'diterima','Komplain diterima','2026-10-17 17:09:22'),(62,21,'diproses','Petugas perbaikan menuju lokasi','2026-10-17 17:09:28'),(63,21,'selesai','Pekerjaan selesai, mohon periksa dan konfirmasi','2026-10-17 17:09:48'),(64,22,'diterima','Komplain diterima','2026-10-17 17:11:38'),(65,22,'diproses','Teknisi sedang dijadwalkan untuk memeriksa kamar Anda','2026-10-17 17:11:48'),(66,22,'selesai','Perbaikan telah selesai dilakukan','2026-10-17 17:12:08'),(67,23,'diterima','Komplain diterima','2026-10-17 17:12:49'),(68,23,'diproses','Teknisi sedang dijadwalkan untuk memeriksa kamar Anda','2026-10-17 17:12:58'),(69,23,'selesai','Perbaikan telah selesai dilakukan','2026-10-17 17:13:18'),(70,24,'diterima','Komplain diterima','2026-10-17 17:18:08'),(71,24,'diproses','Teknisi sedang dijadwalkan untuk memeriksa kamar Anda','2026-10-17 17:18:18'),(72,24,'selesai','Pekerjaan selesai, mohon periksa dan konfirmasi','2026-10-17 17:18:38'),(73,25,'diterima','Komplain diterima','2026-10-17 17:21:06'),(74,25,'diproses','Teknisi sedang dijadwalkan untuk memeriksa kamar Anda','2026-10-17 17:21:18'),(75,25,'selesai','Pekerjaan selesai, mohon periksa dan konfirmasi','2026-10-17 17:21:38'),(76,26,'diterima','Komplain diterima','2026-10-17 17:25:54'),(77,26,'diproses','Teknisi sedang dijadwalkan untuk memeriksa kamar Anda','2026-10-17 17:26:00'),(78,26,'selesai','Pekerjaan selesai, mohon periksa dan konfirmasi','2026-10-17 17:26:16'),(79,27,'diterima','Komplain diterima','2026-10-17 17:28:05'),(80,27,'diproses','Teknisi sedang dijadwalkan untuk memeriksa kamar Anda','2026-10-17 17:28:10'),(81,27,'selesai','Pekerjaan selesai, mohon periksa dan konfirmasi','2026-10-17 17:28:26'),(82,27,'dikonfirmasi','Penyewa mengonfirmasi komplain selesai','2026-10-17 17:28:43');
/*!40000 ALTER TABLE `komplain_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `kos`
--

DROP TABLE IF EXISTS `kos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `kos` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `nama` varchar(120) COLLATE utf8mb4_unicode_ci NOT NULL,
  `alamat` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `lat` decimal(9,6) NOT NULL,
  `lng` decimal(9,6) NOT NULL,
  `deskripsi` text COLLATE utf8mb4_unicode_ci,
  `nama_pemilik` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `kontak_pemilik` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `pemilik_user_id` int unsigned DEFAULT NULL,
  `aktif` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_kos_nama` (`nama`),
  KEY `idx_kos_lokasi` (`lat`,`lng`),
  KEY `idx_kos_pemilik_user` (`pemilik_user_id`),
  CONSTRAINT `fk_kos_pemilik_user` FOREIGN KEY (`pemilik_user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `kos`
--

LOCK TABLES `kos` WRITE;
/*!40000 ALTER TABLE `kos` DISABLE KEYS */;
INSERT INTO `kos` VALUES (1,'Kos Melati','Jl. Contoh No. 5, Limau Manis, Padang',-0.916400,100.461200,'Kos tenang dekat kampus, cocok untuk mahasiswa.','Bu Ratna','081200000001',NULL,1,'2026-10-13 04:14:55'),(2,'Kos Anggrek','Jl. Contoh No. 12, Limau Manis, Padang',-0.919800,100.458900,'Kamar luas dengan AC dan kamar mandi dalam.','Pak Hendra','081200000002',NULL,1,'2026-10-13 04:14:55'),(3,'Kos Kenanga','Jl. Contoh No. 21, Limau Manis, Padang',-0.912500,100.465300,'Kos sederhana dengan harga terjangkau.','Bu Maya','081200000003',NULL,1,'2026-10-13 04:14:55'),(4,'Kos Dahlia','Jl. Contoh No. 8, Limau Manis, Padang',-0.921300,100.463800,'Kos bersih dengan dapur bersama dan area parkir.','Pak Rizal','081200000004',NULL,1,'2026-10-13 04:14:55');
/*!40000 ALTER TABLE `kos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `kos_fasilitas`
--

DROP TABLE IF EXISTS `kos_fasilitas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `kos_fasilitas` (
  `kos_id` int unsigned NOT NULL,
  `fasilitas_id` int unsigned NOT NULL,
  PRIMARY KEY (`kos_id`,`fasilitas_id`),
  KEY `fk_kf_fasilitas` (`fasilitas_id`),
  CONSTRAINT `fk_kf_fasilitas` FOREIGN KEY (`fasilitas_id`) REFERENCES `fasilitas` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_kf_kos` FOREIGN KEY (`kos_id`) REFERENCES `kos` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `kos_fasilitas`
--

LOCK TABLES `kos_fasilitas` WRITE;
/*!40000 ALTER TABLE `kos_fasilitas` DISABLE KEYS */;
INSERT INTO `kos_fasilitas` VALUES (1,1),(2,1),(3,1),(4,1),(2,2),(2,3),(1,4),(2,4),(3,4),(4,4),(1,5),(2,5),(3,5),(4,5),(1,6),(2,6),(4,7),(1,8),(3,8),(4,8),(4,9),(2,10);
/*!40000 ALTER TABLE `kos_fasilitas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `kos_foto`
--

DROP TABLE IF EXISTS `kos_foto`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `kos_foto` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `kos_id` int unsigned NOT NULL,
  `path` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `urutan` tinyint unsigned NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `idx_kos_foto_kos` (`kos_id`),
  CONSTRAINT `fk_kos_foto_kos` FOREIGN KEY (`kos_id`) REFERENCES `kos` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `kos_foto`
--

LOCK TABLES `kos_foto` WRITE;
/*!40000 ALTER TABLE `kos_foto` DISABLE KEYS */;
INSERT INTO `kos_foto` VALUES (1,1,'kos/kos-melati-1.jpg',1),(2,1,'kos/kos-melati-2.jpg',2),(3,2,'kos/kos-anggrek-1.jpg',1),(4,3,'kos/kos-kenanga-1.jpg',1),(5,4,'kos/kos-dahlia-1.jpg',1);
/*!40000 ALTER TABLE `kos_foto` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `riwayat_pencarian`
--

DROP TABLE IF EXISTS `riwayat_pencarian`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `riwayat_pencarian` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int unsigned NOT NULL,
  `kata_kunci` varchar(120) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_riwayat_user` (`user_id`,`created_at`),
  CONSTRAINT `fk_riwayat_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `riwayat_pencarian`
--

LOCK TABLES `riwayat_pencarian` WRITE;
/*!40000 ALTER TABLE `riwayat_pencarian` DISABLE KEYS */;
/*!40000 ALTER TABLE `riwayat_pencarian` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tagihan`
--

DROP TABLE IF EXISTS `tagihan`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tagihan` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `booking_id` int unsigned NOT NULL,
  `periode` date NOT NULL,
  `jumlah` int unsigned NOT NULL,
  `jatuh_tempo` date NOT NULL,
  `status` enum('belum_bayar','menunggu_verifikasi','lunas','ditolak','terlambat') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'belum_bayar',
  `tgl_lunas` date DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_tagihan_periode` (`booking_id`,`periode`),
  KEY `idx_tagihan_status` (`status`,`jatuh_tempo`),
  CONSTRAINT `fk_tagihan_booking` FOREIGN KEY (`booking_id`) REFERENCES `booking` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tagihan`
--

LOCK TABLES `tagihan` WRITE;
/*!40000 ALTER TABLE `tagihan` DISABLE KEYS */;
/*!40000 ALTER TABLE `tagihan` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ulasan`
--

DROP TABLE IF EXISTS `ulasan`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ulasan` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int unsigned NOT NULL,
  `booking_id` int unsigned NOT NULL,
  `kos_id` int unsigned NOT NULL,
  `rating` tinyint unsigned NOT NULL,
  `komentar` varchar(1000) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_ulasan_booking` (`booking_id`),
  KEY `idx_ulasan_kos` (`kos_id`,`rating`),
  KEY `idx_ulasan_user` (`user_id`),
  CONSTRAINT `fk_ulasan_booking` FOREIGN KEY (`booking_id`) REFERENCES `booking` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_ulasan_kos` FOREIGN KEY (`kos_id`) REFERENCES `kos` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_ulasan_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `chk_ulasan_rating` CHECK ((`rating` between 1 and 5))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ulasan`
--

LOCK TABLES `ulasan` WRITE;
/*!40000 ALTER TABLE `ulasan` DISABLE KEYS */;
/*!40000 ALTER TABLE `ulasan` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ulasan_foto`
--

DROP TABLE IF EXISTS `ulasan_foto`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ulasan_foto` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `ulasan_id` int unsigned NOT NULL,
  `path` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_ulasan_foto` (`ulasan_id`),
  CONSTRAINT `fk_ulasan_foto` FOREIGN KEY (`ulasan_id`) REFERENCES `ulasan` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ulasan_foto`
--

LOCK TABLES `ulasan_foto` WRITE;
/*!40000 ALTER TABLE `ulasan_foto` DISABLE KEYS */;
/*!40000 ALTER TABLE `ulasan_foto` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `nama` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `no_hp` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `password_hash` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `role` enum('penyewa','pemilik') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'penyewa',
  `foto_profil` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_users_email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'Penyewa Uji','uji@sikos.test','081200009999','bukan-hash-asli-hanya-untuk-uji','penyewa',NULL,'2026-10-17 01:06:20','2026-10-17 01:06:20');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
SET @@SESSION.SQL_LOG_BIN = @MYSQLDUMP_TEMP_LOG_BIN;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-10-18 15:55:13
