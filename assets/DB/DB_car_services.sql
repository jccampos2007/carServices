CREATE DATABASE  IF NOT EXISTS `car_services` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `car_services`;
-- MySQL dump 10.13  Distrib 8.0.41, for Win64 (x86_64)
--
-- Host: localhost    Database: car_services
-- ------------------------------------------------------
-- Server version	8.0.42-0ubuntu0.20.04.1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `biling_period`
--

DROP TABLE IF EXISTS `biling_period`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `biling_period` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) DEFAULT NULL,
  `createdAt` datetime DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `biling_period`
--

LOCK TABLES `biling_period` WRITE;
/*!40000 ALTER TABLE `biling_period` DISABLE KEYS */;
/*!40000 ALTER TABLE `biling_period` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `make`
--

DROP TABLE IF EXISTS `make`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `make` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(150) DEFAULT NULL,
  `createdAt` datetime DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `make`
--

LOCK TABLES `make` WRITE;
/*!40000 ALTER TABLE `make` DISABLE KEYS */;
INSERT INTO `make` VALUES (1,'Chevrolet','2025-09-16 14:33:30',NULL),(2,'Toyota','2025-09-16 14:34:43',NULL),(3,'Ford','2025-09-16 14:34:43',NULL),(4,'Jeep','2025-09-16 14:34:43',NULL),(5,'Chery','2025-09-16 14:34:43',NULL),(6,'Hyundai','2025-09-16 14:34:43',NULL),(7,'Kia','2025-09-16 14:34:43',NULL),(8,'Volkswagen','2025-09-16 14:34:43',NULL),(9,'Renault','2025-09-16 14:35:42',NULL),(10,'Fiat','2025-09-16 14:35:42',NULL),(11,'Mitsubishi','2025-09-16 14:35:42',NULL),(12,'Mazda','2025-09-16 14:36:21',NULL);
/*!40000 ALTER TABLE `make` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `model_vehicle`
--

DROP TABLE IF EXISTS `model_vehicle`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `model_vehicle` (
  `id` int NOT NULL AUTO_INCREMENT,
  `id_make` int DEFAULT NULL,
  `name` varchar(150) DEFAULT NULL,
  `createApt` datetime DEFAULT CURRENT_TIMESTAMP,
  `updateApt` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=181 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `model_vehicle`
--

LOCK TABLES `model_vehicle` WRITE;
/*!40000 ALTER TABLE `model_vehicle` DISABLE KEYS */;
INSERT INTO `model_vehicle` VALUES (1,1,'Onix','2025-09-24 20:00:11',NULL),(2,1,'Aveo','2025-09-24 20:00:11',NULL),(3,1,'Malibu','2025-09-24 20:00:11',NULL),(4,1,'Spark','2025-09-24 20:00:11',NULL),(5,1,'Tracker','2025-09-24 20:00:11',NULL),(6,1,'Captiva','2025-09-24 20:00:11',NULL),(7,1,'Equinox','2025-09-24 20:00:11',NULL),(8,1,'Traverse','2025-09-24 20:00:11',NULL),(9,1,'Tahoe','2025-09-24 20:00:11',NULL),(10,1,'Suburban','2025-09-24 20:00:11',NULL),(11,1,'Montana','2025-09-24 20:00:11',NULL),(12,1,'S10','2025-09-24 20:00:11',NULL),(13,1,'Silverado','2025-09-24 20:00:11',NULL),(14,1,'Camaro','2025-09-24 20:00:11',NULL),(15,1,'Corvette','2025-09-24 20:00:11',NULL),(16,1,'Bolt EV','2025-09-24 20:00:11',NULL),(17,1,'Bolt EUV','2025-09-24 20:00:11',NULL),(18,1,'Silverado EV','2025-09-24 20:00:11',NULL),(19,1,'Equinox EV','2025-09-24 20:00:11',NULL),(20,2,'Corolla','2025-09-24 20:01:16',NULL),(21,2,'Camry','2025-09-24 20:01:16',NULL),(22,2,'Yaris','2025-09-24 20:01:16',NULL),(23,2,'Prius','2025-09-24 20:01:16',NULL),(24,2,'Supra','2025-09-24 20:01:16',NULL),(25,2,'GR86','2025-09-24 20:01:16',NULL),(26,2,'RAV4','2025-09-24 20:01:16',NULL),(27,2,'Highlander','2025-09-24 20:01:16',NULL),(28,2,'4Runner','2025-09-24 20:01:16',NULL),(29,2,'Sequoia','2025-09-24 20:01:16',NULL),(30,2,'Land Cruiser','2025-09-24 20:01:16',NULL),(31,2,'Tacoma','2025-09-24 20:01:16',NULL),(32,2,'Tundra','2025-09-24 20:01:16',NULL),(33,2,'Sienna','2025-09-24 20:01:16',NULL),(34,2,'Mirai','2025-09-24 20:01:16',NULL),(35,2,'bZ4X','2025-09-24 20:01:16',NULL),(36,3,'Fiesta','2025-09-24 20:01:44',NULL),(37,3,'Focus','2025-09-24 20:01:44',NULL),(38,3,'Fusion','2025-09-24 20:01:44',NULL),(39,3,'Mustang','2025-09-24 20:01:44',NULL),(40,3,'Mustang Mach-E','2025-09-24 20:01:44',NULL),(41,3,'Escape','2025-09-24 20:01:44',NULL),(42,3,'Bronco','2025-09-24 20:01:44',NULL),(43,3,'Explorer','2025-09-24 20:01:44',NULL),(44,3,'Expedition','2025-09-24 20:01:44',NULL),(45,3,'Ranger','2025-09-24 20:01:44',NULL),(46,3,'F-150','2025-09-24 20:01:44',NULL),(47,3,'Maverick','2025-09-24 20:01:44',NULL),(48,3,'F-150 Lightning','2025-09-24 20:01:44',NULL),(49,3,'Transit','2025-09-24 20:01:44',NULL),(50,3,'E-Transit','2025-09-24 20:01:44',NULL),(51,4,'Wrangler','2025-09-24 20:02:08',NULL),(52,4,'Cherokee','2025-09-24 20:02:08',NULL),(53,4,'Grand Cherokee','2025-09-24 20:02:08',NULL),(54,4,'Renegade','2025-09-24 20:02:08',NULL),(55,4,'Compass','2025-09-24 20:02:08',NULL),(56,4,'Gladiator','2025-09-24 20:02:08',NULL),(57,4,'Patriot','2025-09-24 20:02:08',NULL),(58,4,'Liberty','2025-09-24 20:02:08',NULL),(59,5,'Tiggo 2','2025-09-24 20:04:59',NULL),(60,5,'Tiggo 3x','2025-09-24 20:04:59',NULL),(61,5,'Tiggo 4 Pro','2025-09-24 20:04:59',NULL),(62,5,'Tiggo 5x','2025-09-24 20:04:59',NULL),(63,5,'Tiggo 7 Pro','2025-09-24 20:04:59',NULL),(64,5,'Tiggo 8 Pro Max','2025-09-24 20:04:59',NULL),(65,5,'Tiggo 9','2025-09-24 20:04:59',NULL),(66,5,'Arrizo 5','2025-09-24 20:04:59',NULL),(67,5,'Arrizo 6 Pro','2025-09-24 20:04:59',NULL),(68,5,'Arrizo 8','2025-09-24 20:04:59',NULL),(69,5,'Omoda 5','2025-09-24 20:04:59',NULL),(70,5,'Omoda E5','2025-09-24 20:04:59',NULL),(71,5,'Jaecoo J7','2025-09-24 20:04:59',NULL),(72,5,'Jaecoo J8','2025-09-24 20:04:59',NULL),(73,5,'Fulwin A8','2025-09-24 20:04:59',NULL),(74,5,'Fulwin T9','2025-09-24 20:04:59',NULL),(75,5,'QQ Ice Cream','2025-09-24 20:04:59',NULL),(76,5,'QQ Wujie Pro','2025-09-24 20:04:59',NULL),(77,5,'QQ Little Ant','2025-09-24 20:04:59',NULL),(78,5,'eQ1','2025-09-24 20:04:59',NULL),(79,5,'eQ2','2025-09-24 20:04:59',NULL),(80,5,'eQ5','2025-09-24 20:04:59',NULL),(81,5,'Arrizo 5 GT','2025-09-24 20:04:59',NULL),(82,5,'Arrizo 5 Plus','2025-09-24 20:04:59',NULL),(83,5,'Tansuo 06','2025-09-24 20:04:59',NULL),(84,5,'Arauca','2025-09-24 20:04:59',NULL),(85,5,'Orinoco','2025-09-24 20:04:59',NULL),(86,6,'Accent','2025-09-24 20:05:22',NULL),(87,6,'Elantra','2025-09-24 20:05:22',NULL),(88,6,'Sonata','2025-09-24 20:05:22',NULL),(89,6,'Ioniq 5','2025-09-24 20:05:22',NULL),(90,6,'Ioniq 6','2025-09-24 20:05:22',NULL),(91,6,'Kona','2025-09-24 20:05:22',NULL),(92,6,'Venue','2025-09-24 20:05:22',NULL),(93,6,'Tucson','2025-09-24 20:05:22',NULL),(94,6,'Santa Fe','2025-09-24 20:05:22',NULL),(95,6,'Palisade','2025-09-24 20:05:22',NULL),(96,6,'Creta','2025-09-24 20:05:22',NULL),(97,6,'Grand i10','2025-09-24 20:05:22',NULL),(98,6,'i20','2025-09-24 20:05:22',NULL),(99,6,'i30','2025-09-24 20:05:22',NULL),(100,6,'Nexo','2025-09-24 20:05:22',NULL),(101,7,'Picanto','2025-09-24 20:05:48',NULL),(102,7,'Rio','2025-09-24 20:05:48',NULL),(103,7,'Forte','2025-09-24 20:05:48',NULL),(104,7,'K5','2025-09-24 20:05:48',NULL),(105,7,'K3','2025-09-24 20:05:48',NULL),(106,7,'Seltos','2025-09-24 20:05:48',NULL),(107,7,'Sportage','2025-09-24 20:05:48',NULL),(108,7,'Sorento','2025-09-24 20:05:48',NULL),(109,7,'Telluride','2025-09-24 20:05:48',NULL),(110,7,'Carnival','2025-09-24 20:05:48',NULL),(111,7,'Soul','2025-09-24 20:05:48',NULL),(112,7,'Niro','2025-09-24 20:05:48',NULL),(113,7,'EV6','2025-09-24 20:05:48',NULL),(114,7,'EV9','2025-09-24 20:05:48',NULL),(115,8,'Gol','2025-09-24 20:06:18',NULL),(116,8,'Polo','2025-09-24 20:06:18',NULL),(117,8,'Jetta','2025-09-24 20:06:18',NULL),(118,8,'Passat','2025-09-24 20:06:18',NULL),(119,8,'Beetle','2025-09-24 20:06:18',NULL),(120,8,'Golf','2025-09-24 20:06:18',NULL),(121,8,'Tiguan','2025-09-24 20:06:18',NULL),(122,8,'T-Cross','2025-09-24 20:06:18',NULL),(123,8,'Taos','2025-09-24 20:06:18',NULL),(124,8,'Touareg','2025-09-24 20:06:18',NULL),(125,8,'Atlas','2025-09-24 20:06:18',NULL),(126,8,'Amarok','2025-09-24 20:06:18',NULL),(127,8,'ID.3','2025-09-24 20:06:18',NULL),(128,8,'ID.4','2025-09-24 20:06:18',NULL),(129,8,'ID.5','2025-09-24 20:06:18',NULL),(130,8,'ID. Buzz','2025-09-24 20:06:18',NULL),(131,9,'Kwid','2025-09-24 20:06:41',NULL),(132,9,'Clio','2025-09-24 20:06:41',NULL),(133,9,'Twingo','2025-09-24 20:06:41',NULL),(134,9,'Sandero','2025-09-24 20:06:41',NULL),(135,9,'Logan','2025-09-24 20:06:41',NULL),(136,9,'Captur','2025-09-24 20:06:41',NULL),(137,9,'Kiger','2025-09-24 20:06:41',NULL),(138,9,'Duster','2025-09-24 20:06:41',NULL),(139,9,'Arkana','2025-09-24 20:06:41',NULL),(140,9,'Koleos','2025-09-24 20:06:41',NULL),(141,9,'Espace','2025-09-24 20:06:41',NULL),(142,9,'Megane E-Tech','2025-09-24 20:06:41',NULL),(143,9,'Zoe','2025-09-24 20:06:41',NULL),(144,9,'Talisman','2025-09-24 20:06:41',NULL),(145,9,'Austral','2025-09-24 20:06:41',NULL),(146,9,'Kangoo','2025-09-24 20:06:41',NULL),(147,10,'500','2025-09-24 20:07:06',NULL),(148,10,'500e','2025-09-24 20:07:06',NULL),(149,10,'500X','2025-09-24 20:07:06',NULL),(150,10,'Panda','2025-09-24 20:07:06',NULL),(151,10,'Tipo','2025-09-24 20:07:06',NULL),(152,10,'Uno','2025-09-24 20:07:06',NULL),(153,10,'Palio','2025-09-24 20:07:06',NULL),(154,10,'Siena','2025-09-24 20:07:06',NULL),(155,10,'Argo','2025-09-24 20:07:06',NULL),(156,10,'Mobi','2025-09-24 20:07:06',NULL),(157,10,'Cronos','2025-09-24 20:07:06',NULL),(158,10,'Strada','2025-09-24 20:07:06',NULL),(159,10,'Toro','2025-09-24 20:07:06',NULL),(160,11,'ASX','2025-09-24 20:07:33',NULL),(161,11,'Eclipse Cross','2025-09-24 20:07:33',NULL),(162,11,'Outlander','2025-09-24 20:07:33',NULL),(163,11,'Mirage','2025-09-24 20:07:33',NULL),(164,11,'Attrage','2025-09-24 20:07:33',NULL),(165,11,'Lancer','2025-09-24 20:07:33',NULL),(166,11,'L200','2025-09-24 20:07:33',NULL),(167,11,'Montero Sport','2025-09-24 20:07:33',NULL),(168,11,'Montero','2025-09-24 20:07:33',NULL),(169,11,'Grandis','2025-09-24 20:07:33',NULL),(170,12,'Mazda2','2025-09-24 20:08:01',NULL),(171,12,'Mazda3','2025-09-24 20:08:01',NULL),(172,12,'Mazda6','2025-09-24 20:08:01',NULL),(173,12,'CX-3','2025-09-24 20:08:01',NULL),(174,12,'CX-30','2025-09-24 20:08:01',NULL),(175,12,'CX-5','2025-09-24 20:08:01',NULL),(176,12,'CX-50','2025-09-24 20:08:01',NULL),(177,12,'CX-9','2025-09-24 20:08:01',NULL),(178,12,'CX-90','2025-09-24 20:08:01',NULL),(179,12,'MX-5 Miata','2025-09-24 20:08:01',NULL),(180,12,'MX-30','2025-09-24 20:08:01',NULL);
/*!40000 ALTER TABLE `model_vehicle` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payment_due`
--

DROP TABLE IF EXISTS `payment_due`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `payment_due` (
  `id` int NOT NULL AUTO_INCREMENT,
  `id_premium` int DEFAULT NULL,
  `status` int DEFAULT NULL,
  `createdAt` datetime DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payment_due`
--

LOCK TABLES `payment_due` WRITE;
/*!40000 ALTER TABLE `payment_due` DISABLE KEYS */;
/*!40000 ALTER TABLE `payment_due` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `plan`
--

DROP TABLE IF EXISTS `plan`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `plan` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(150) DEFAULT NULL,
  `createdAt` datetime DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `plan`
--

LOCK TABLES `plan` WRITE;
/*!40000 ALTER TABLE `plan` DISABLE KEYS */;
/*!40000 ALTER TABLE `plan` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `plan_price`
--

DROP TABLE IF EXISTS `plan_price`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `plan_price` (
  `id` int NOT NULL AUTO_INCREMENT,
  `id_plan` int DEFAULT NULL,
  `id_biling_period` int DEFAULT NULL,
  `prince` decimal(6,2) DEFAULT '0.00',
  `createdAt` datetime DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `plan_price`
--

LOCK TABLES `plan_price` WRITE;
/*!40000 ALTER TABLE `plan_price` DISABLE KEYS */;
/*!40000 ALTER TABLE `plan_price` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `service`
--

DROP TABLE IF EXISTS `service`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `service` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) DEFAULT NULL,
  `createdAt` datetime DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `service`
--

LOCK TABLES `service` WRITE;
/*!40000 ALTER TABLE `service` DISABLE KEYS */;
INSERT INTO `service` VALUES (1,'Cambio de aceite de motor y filtro','2025-09-24 20:26:26',NULL),(2,'Cambio de fluido de la transmisión','2025-09-24 20:26:26',NULL),(3,'Cambio de fluido del diferencial','2025-09-24 20:26:26',NULL),(4,'Cambio de fluido de la caja de transferencia','2025-09-24 20:26:26',NULL),(5,'Cambio de líquido de frenos','2025-09-24 20:26:26',NULL),(6,'Cambio de líquido de dirección asistida','2025-09-24 20:26:26',NULL),(7,'Cambio de filtro de aire del motor','2025-09-24 20:26:26',NULL),(8,'Cambio de filtro de aire de la cabina','2025-09-24 20:26:26',NULL),(9,'Rotación de neumáticos','2025-09-24 20:26:26',NULL),(10,'Revisión y ajuste de frenos','2025-09-24 20:26:26',NULL),(11,'Cambio de batería','2025-09-24 20:26:26',NULL),(12,'Cambio de neumáticos','2025-09-24 20:26:26',NULL),(13,'Alineación y balanceo','2025-09-24 20:26:26',NULL),(14,'Cambio de correa de distribución','2025-09-24 20:26:26',NULL),(15,'Cambio de bujías','2025-09-24 20:26:26',NULL),(16,'Revisión y reemplazo de amortiguadores','2025-09-24 20:26:26',NULL),(17,'Reemplazo de rodamientos de ruedas','2025-09-24 20:26:26',NULL);
/*!40000 ALTER TABLE `service` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `service_by_vehicle`
--

DROP TABLE IF EXISTS `service_by_vehicle`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `service_by_vehicle` (
  `id` int NOT NULL AUTO_INCREMENT,
  `id_service` int DEFAULT NULL,
  `id_vehicle_by_user` int DEFAULT NULL,
  `details` varchar(256) DEFAULT NULL,
  `initial_mileage` int DEFAULT NULL,
  `final_mileage` int DEFAULT NULL,
  `rubbers` int DEFAULT '0' COMMENT '1: delantero derecho; 2: delantero izquierdo; 3: tracero derecho; 4: tracero izquierdo',
  `createdAt` datetime DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `service_by_vehicle`
--

LOCK TABLES `service_by_vehicle` WRITE;
/*!40000 ALTER TABLE `service_by_vehicle` DISABLE KEYS */;
/*!40000 ALTER TABLE `service_by_vehicle` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user`
--

DROP TABLE IF EXISTS `user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user` (
  `id` int NOT NULL AUTO_INCREMENT,
  `first_name` varchar(100) DEFAULT NULL,
  `last_name` varchar(100) DEFAULT NULL,
  `phone` varchar(50) DEFAULT NULL,
  `email` varchar(256) DEFAULT NULL,
  `is_premium` tinyint(1) DEFAULT '0' COMMENT '0: no; 1: yes',
  `createdAt` datetime DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user`
--

LOCK TABLES `user` WRITE;
/*!40000 ALTER TABLE `user` DISABLE KEYS */;
INSERT INTO `user` VALUES (1,'juan','campos',NULL,NULL,0,'2025-09-24 18:36:41',NULL);
/*!40000 ALTER TABLE `user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_by_plan_price`
--

DROP TABLE IF EXISTS `user_by_plan_price`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_by_plan_price` (
  `id` int NOT NULL AUTO_INCREMENT,
  `id_user` int DEFAULT NULL,
  `id_plan_price` int DEFAULT NULL,
  `createdAt` datetime DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_by_plan_price`
--

LOCK TABLES `user_by_plan_price` WRITE;
/*!40000 ALTER TABLE `user_by_plan_price` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_by_plan_price` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `vehicle_by_user`
--

DROP TABLE IF EXISTS `vehicle_by_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `vehicle_by_user` (
  `id` int NOT NULL AUTO_INCREMENT,
  `id_user` int DEFAULT NULL,
  `id_model` int DEFAULT NULL,
  `year` int DEFAULT NULL,
  `image` text,
  `createApt` datetime DEFAULT CURRENT_TIMESTAMP,
  `updateApt` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `vehicle_by_user`
--

LOCK TABLES `vehicle_by_user` WRITE;
/*!40000 ALTER TABLE `vehicle_by_user` DISABLE KEYS */;
INSERT INTO `vehicle_by_user` VALUES (1,1,84,2013,'https://cdn.wheel-size.com/automobile/body/chery-arauca-2007-2016-1706007453.4994285.jpg','2025-09-24 18:37:27','2025-09-24 20:08:56');
/*!40000 ALTER TABLE `vehicle_by_user` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-09-29 10:39:42
