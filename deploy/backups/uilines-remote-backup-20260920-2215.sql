-- MySQL dump 10.13  Distrib 8.4.11, for Linux (x86_64)
--
-- Host: localhost    Database: uilines
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

--
-- Table structure for table `account`
--

DROP TABLE IF EXISTS `account`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `account` (
  `id` varchar(36) NOT NULL,
  `accountId` varchar(255) NOT NULL,
  `providerId` varchar(255) NOT NULL,
  `userId` varchar(36) NOT NULL,
  `accessToken` text,
  `refreshToken` text,
  `idToken` text,
  `accessTokenExpiresAt` timestamp NULL DEFAULT NULL,
  `refreshTokenExpiresAt` timestamp NULL DEFAULT NULL,
  `scope` text,
  `password` text,
  `createdAt` timestamp NOT NULL DEFAULT (now()),
  `updatedAt` timestamp NOT NULL DEFAULT (now()) ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_account_userId` (`userId`),
  CONSTRAINT `account_userId_user_id_fk` FOREIGN KEY (`userId`) REFERENCES `user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `account`
--

LOCK TABLES `account` WRITE;
/*!40000 ALTER TABLE `account` DISABLE KEYS */;
INSERT INTO `account` VALUES ('fTVJdb78UaHvPTBnZ8pSsiROb87UaSm3','UJZd1gQ2pUHHMAkoHHapNY9QW54yEile','credential','UJZd1gQ2pUHHMAkoHHapNY9QW54yEile',NULL,NULL,NULL,NULL,NULL,NULL,'1d1120d6e8a0d1de5dbd73928dabbe7c:d7cfc50fd30c5ce3e60d41b8f173528febb7a9cb0581023c824f4d7d92e53d9c23336c4a2f9b67a899a2db295202d2268dda0ce37d1d6ed588e2140e277dc7af','2026-09-18 12:16:20','2026-09-18 12:16:20'),('IgJXgwFGQkn9vWTfgu80CSAVskJB58Nr','79UhVSTRB4Oh5ibyIoJfR2JqvkI5NXdb','credential','79UhVSTRB4Oh5ibyIoJfR2JqvkI5NXdb',NULL,NULL,NULL,NULL,NULL,NULL,'e04285d312abc69f78a7ccea593f620e:6272edfe59008802a17041a350b8760e6c3dc3f93fe76b99573f3826919fa4b09c7c0ad808bc366735c6d7b3ec3c536c5f241dcb65990ec8aef49af5d42f12f2','2026-09-18 15:29:23','2026-09-18 15:29:23'),('IPfPpGiEEvcC4nXCXYb8rVHTw6shUXm5','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6','credential','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6',NULL,NULL,NULL,NULL,NULL,NULL,'941e908e53d8f1f4d5273977af9a0c85:f79e65b30eb85c54561eab08821e5d2d110ab819506bf4c6885213dacfce17055983a883359ecd36af8697a9ab75bbb2757d4a3d601906b6c7253c0cb3526b0d','2026-09-16 11:46:52','2026-09-16 11:46:52'),('mtWBHlHgMlc4Wec1yY2N4PeC0wvA6FWP','rXi36d6MyI8p0fn8rRhZwMiR5GGA7SVT','credential','rXi36d6MyI8p0fn8rRhZwMiR5GGA7SVT',NULL,NULL,NULL,NULL,NULL,NULL,'40d1ec7cdcc62bc8d8de5c53e4f59add:78864df1fe5c875665f6c61993599db44885c2e76dcb2e21331239c31320c6ab589b986ed4a86d554738293f1a60f5094db801aef1ee481a15535e9004da1624','2026-09-17 14:46:59','2026-09-18 15:37:23'),('ToP6vvL9SBT27xpomrYRJCGzZWuqF03u','1wKpQRdHAxKWEvupzUVg1CPWEku04eAk','credential','1wKpQRdHAxKWEvupzUVg1CPWEku04eAk',NULL,NULL,NULL,NULL,NULL,NULL,'1d00d9c4dd4cc57cad64479710fa188a:f6932708f5843aba0d64bf9a92f042cf399495c9d349b108ccbe729f0c78b916b251f3a45d8eba7bfed6c72be9a957fe6a98721ce2efa2b3634bff00f2c9e7eb','2026-09-18 20:31:36','2026-09-18 20:31:36');
/*!40000 ALTER TABLE `account` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `addresses`
--

DROP TABLE IF EXISTS `addresses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `addresses` (
  `id` int NOT NULL AUTO_INCREMENT,
  `userId` varchar(36) NOT NULL,
  `recipientName` varchar(100) NOT NULL,
  `phone` varchar(32) NOT NULL,
  `country` varchar(100) NOT NULL,
  `province` varchar(100) DEFAULT NULL,
  `city` varchar(100) DEFAULT NULL,
  `district` varchar(100) DEFAULT NULL,
  `addressLine1` varchar(255) NOT NULL,
  `addressLine2` varchar(255) DEFAULT NULL,
  `postalCode` varchar(32) DEFAULT NULL,
  `isDefault` tinyint(1) NOT NULL DEFAULT '0',
  `createdAt` timestamp NOT NULL DEFAULT (now()),
  `updatedAt` timestamp NOT NULL DEFAULT (now()) ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_addresses_userId_isDefault` (`userId`,`isDefault`),
  CONSTRAINT `addresses_userId_user_id_fk` FOREIGN KEY (`userId`) REFERENCES `user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `addresses`
--

LOCK TABLES `addresses` WRITE;
/*!40000 ALTER TABLE `addresses` DISABLE KEYS */;
INSERT INTO `addresses` VALUES (4,'MtTk43nCRWicn9XwqYobCc2DIU2uqbI6','kjllfda','87326189637218','dsafdsa','fdsa','ds',NULL,'fakjkfldsajfdkla',NULL,'fda',0,'2026-09-17 14:39:32','2026-09-18 12:05:17'),(6,'UJZd1gQ2pUHHMAkoHHapNY9QW54yEile','fjdska','8493215432','中国','Sichuan, chengdu','fdsa','ewerw','Sichuan , Chengdu city,',NULL,'620500',1,'2026-09-18 12:17:31','2026-09-18 12:17:31'),(16,'UJZd1gQ2pUHHMAkoHHapNY9QW54yEile','fsdafdsa','iuy4382y5482','fdsa','fdsa','werewq','fdsafds','dfsa',NULL,'afdsafdsa',0,'2026-09-18 12:31:35','2026-09-18 12:31:35'),(20,'1wKpQRdHAxKWEvupzUVg1CPWEku04eAk','hfcch','4567874332','ghese','gcvj','gvvvb',NULL,'gcc. v',NULL,'ttfcc',1,'2026-09-18 20:33:30','2026-09-18 20:33:30');
/*!40000 ALTER TABLE `addresses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `admin_role_permissions`
--

DROP TABLE IF EXISTS `admin_role_permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `admin_role_permissions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `roleId` varchar(36) NOT NULL,
  `permissionKey` varchar(128) NOT NULL,
  `createdAt` timestamp NOT NULL DEFAULT (now()),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_admin_role_permission` (`roleId`,`permissionKey`),
  KEY `idx_admin_role_permissions_roleId` (`roleId`),
  CONSTRAINT `admin_role_permissions_roleId_admin_roles_id_fk` FOREIGN KEY (`roleId`) REFERENCES `admin_roles` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=197 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `admin_role_permissions`
--

LOCK TABLES `admin_role_permissions` WRITE;
/*!40000 ALTER TABLE `admin_role_permissions` DISABLE KEYS */;
INSERT INTO `admin_role_permissions` VALUES (53,'2ce8b5c5-6b24-477f-8f22-526c421f2aca','/admin:view','2026-09-18 15:34:52'),(54,'2ce8b5c5-6b24-477f-8f22-526c421f2aca','/admin:update','2026-09-18 15:34:52'),(55,'2ce8b5c5-6b24-477f-8f22-526c421f2aca','/admin/products:view','2026-09-18 15:34:52'),(56,'2ce8b5c5-6b24-477f-8f22-526c421f2aca','/admin/products:create','2026-09-18 15:34:52'),(57,'2ce8b5c5-6b24-477f-8f22-526c421f2aca','/admin/products:update','2026-09-18 15:34:52'),(58,'2ce8b5c5-6b24-477f-8f22-526c421f2aca','/admin/products:delete','2026-09-18 15:34:52'),(59,'2ce8b5c5-6b24-477f-8f22-526c421f2aca','/admin/categories:view','2026-09-18 15:34:52'),(60,'2ce8b5c5-6b24-477f-8f22-526c421f2aca','/admin/categories:create','2026-09-18 15:34:52'),(61,'2ce8b5c5-6b24-477f-8f22-526c421f2aca','/admin/categories:update','2026-09-18 15:34:52'),(62,'2ce8b5c5-6b24-477f-8f22-526c421f2aca','/admin/categories:delete','2026-09-18 15:34:52'),(63,'2ce8b5c5-6b24-477f-8f22-526c421f2aca','/admin/product-attributes:view','2026-09-18 15:34:52'),(64,'2ce8b5c5-6b24-477f-8f22-526c421f2aca','/admin/product-attributes:create','2026-09-18 15:34:52'),(65,'2ce8b5c5-6b24-477f-8f22-526c421f2aca','/admin/product-attributes:update','2026-09-18 15:34:52'),(66,'2ce8b5c5-6b24-477f-8f22-526c421f2aca','/admin/product-attributes:delete','2026-09-18 15:34:52'),(67,'2ce8b5c5-6b24-477f-8f22-526c421f2aca','/admin/orders:view','2026-09-18 15:34:52'),(68,'2ce8b5c5-6b24-477f-8f22-526c421f2aca','/admin/orders:update','2026-09-18 15:34:52'),(69,'2ce8b5c5-6b24-477f-8f22-526c421f2aca','/admin/coupons:view','2026-09-18 15:34:52'),(70,'2ce8b5c5-6b24-477f-8f22-526c421f2aca','/admin/coupons:create','2026-09-18 15:34:52'),(71,'2ce8b5c5-6b24-477f-8f22-526c421f2aca','/admin/coupons:update','2026-09-18 15:34:52'),(72,'2ce8b5c5-6b24-477f-8f22-526c421f2aca','/admin/coupons:delete','2026-09-18 15:34:52'),(73,'2ce8b5c5-6b24-477f-8f22-526c421f2aca','/admin/customers:view','2026-09-18 15:34:52'),(74,'2ce8b5c5-6b24-477f-8f22-526c421f2aca','/admin/customers:update','2026-09-18 15:34:52'),(75,'2ce8b5c5-6b24-477f-8f22-526c421f2aca','/admin/customers:delete','2026-09-18 15:34:52'),(76,'2ce8b5c5-6b24-477f-8f22-526c421f2aca','/admin/reviews:view','2026-09-18 15:34:52'),(77,'2ce8b5c5-6b24-477f-8f22-526c421f2aca','/admin/reviews:update','2026-09-18 15:34:52'),(78,'2ce8b5c5-6b24-477f-8f22-526c421f2aca','/admin/reviews:delete','2026-09-18 15:34:52'),(79,'2ce8b5c5-6b24-477f-8f22-526c421f2aca','/admin/member-logs:view','2026-09-18 15:34:52'),(80,'2ce8b5c5-6b24-477f-8f22-526c421f2aca','/admin/blogs:view','2026-09-18 15:34:52'),(81,'2ce8b5c5-6b24-477f-8f22-526c421f2aca','/admin/blogs:create','2026-09-18 15:34:52'),(82,'2ce8b5c5-6b24-477f-8f22-526c421f2aca','/admin/blogs:update','2026-09-18 15:34:52'),(83,'2ce8b5c5-6b24-477f-8f22-526c421f2aca','/admin/blogs:delete','2026-09-18 15:34:52'),(84,'2ce8b5c5-6b24-477f-8f22-526c421f2aca','/admin/blog-categories:view','2026-09-18 15:34:52'),(85,'2ce8b5c5-6b24-477f-8f22-526c421f2aca','/admin/blog-categories:create','2026-09-18 15:34:52'),(86,'2ce8b5c5-6b24-477f-8f22-526c421f2aca','/admin/blog-categories:update','2026-09-18 15:34:52'),(87,'2ce8b5c5-6b24-477f-8f22-526c421f2aca','/admin/blog-categories:delete','2026-09-18 15:34:52'),(88,'2ce8b5c5-6b24-477f-8f22-526c421f2aca','/admin/announcements:view','2026-09-18 15:34:52'),(89,'2ce8b5c5-6b24-477f-8f22-526c421f2aca','/admin/announcements:create','2026-09-18 15:34:52'),(90,'2ce8b5c5-6b24-477f-8f22-526c421f2aca','/admin/announcements:update','2026-09-18 15:34:52'),(91,'2ce8b5c5-6b24-477f-8f22-526c421f2aca','/admin/announcements:delete','2026-09-18 15:34:52'),(92,'2ce8b5c5-6b24-477f-8f22-526c421f2aca','/admin/messages:view','2026-09-18 15:34:52'),(93,'2ce8b5c5-6b24-477f-8f22-526c421f2aca','/admin/messages:update','2026-09-18 15:34:52'),(94,'2ce8b5c5-6b24-477f-8f22-526c421f2aca','/admin/messages:delete','2026-09-18 15:34:52'),(95,'2ce8b5c5-6b24-477f-8f22-526c421f2aca','/admin/subscribers:view','2026-09-18 15:34:52'),(96,'2ce8b5c5-6b24-477f-8f22-526c421f2aca','/admin/subscribers:update','2026-09-18 15:34:52'),(97,'2ce8b5c5-6b24-477f-8f22-526c421f2aca','/admin/subscribers:delete','2026-09-18 15:34:52'),(98,'2ce8b5c5-6b24-477f-8f22-526c421f2aca','/admin/administrators:view','2026-09-18 15:34:52'),(99,'2ce8b5c5-6b24-477f-8f22-526c421f2aca','/admin/administrators:create','2026-09-18 15:34:52'),(100,'2ce8b5c5-6b24-477f-8f22-526c421f2aca','/admin/administrators:update','2026-09-18 15:34:52'),(101,'2ce8b5c5-6b24-477f-8f22-526c421f2aca','/admin/administrators:delete','2026-09-18 15:34:52'),(102,'2ce8b5c5-6b24-477f-8f22-526c421f2aca','/admin/roles:view','2026-09-18 15:34:52'),(103,'2ce8b5c5-6b24-477f-8f22-526c421f2aca','/admin/roles:create','2026-09-18 15:34:52'),(104,'2ce8b5c5-6b24-477f-8f22-526c421f2aca','/admin/roles:update','2026-09-18 15:34:52'),(105,'2ce8b5c5-6b24-477f-8f22-526c421f2aca','/admin/roles:delete','2026-09-18 15:34:52'),(106,'85402eb0-c874-4920-9304-226e326437a2','/admin:view','2026-09-18 15:34:52'),(108,'85402eb0-c874-4920-9304-226e326437a2','/admin/announcements:view','2026-09-18 15:34:52'),(109,'85402eb0-c874-4920-9304-226e326437a2','/admin/announcements:create','2026-09-18 15:34:52'),(112,'85402eb0-c874-4920-9304-226e326437a2','/admin/blog-categories:view','2026-09-18 15:34:52'),(113,'85402eb0-c874-4920-9304-226e326437a2','/admin/blog-categories:create','2026-09-18 15:34:52'),(116,'85402eb0-c874-4920-9304-226e326437a2','/admin/blogs:view','2026-09-18 15:34:52'),(117,'85402eb0-c874-4920-9304-226e326437a2','/admin/blogs:create','2026-09-18 15:34:52'),(120,'85402eb0-c874-4920-9304-226e326437a2','/admin/categories:view','2026-09-18 15:34:52'),(121,'85402eb0-c874-4920-9304-226e326437a2','/admin/categories:create','2026-09-18 15:34:52'),(124,'85402eb0-c874-4920-9304-226e326437a2','/admin/coupons:view','2026-09-18 15:34:52'),(125,'85402eb0-c874-4920-9304-226e326437a2','/admin/coupons:create','2026-09-18 15:34:52'),(128,'85402eb0-c874-4920-9304-226e326437a2','/admin/customers:view','2026-09-18 15:34:52'),(131,'85402eb0-c874-4920-9304-226e326437a2','/admin/member-logs:view','2026-09-18 15:34:52'),(132,'85402eb0-c874-4920-9304-226e326437a2','/admin/messages:view','2026-09-18 15:34:52'),(135,'85402eb0-c874-4920-9304-226e326437a2','/admin/orders:view','2026-09-18 15:34:52'),(137,'85402eb0-c874-4920-9304-226e326437a2','/admin/product-attributes:view','2026-09-18 15:34:52'),(138,'85402eb0-c874-4920-9304-226e326437a2','/admin/product-attributes:create','2026-09-18 15:34:52'),(141,'85402eb0-c874-4920-9304-226e326437a2','/admin/products:view','2026-09-18 15:34:52'),(142,'85402eb0-c874-4920-9304-226e326437a2','/admin/products:create','2026-09-18 15:34:52'),(145,'85402eb0-c874-4920-9304-226e326437a2','/admin/reviews:view','2026-09-18 15:34:52'),(148,'85402eb0-c874-4920-9304-226e326437a2','/admin/subscribers:view','2026-09-18 15:34:52'),(151,'caea986b-a101-448e-ac5f-d6744a1cba31','/admin:view','2026-09-18 15:34:52'),(152,'caea986b-a101-448e-ac5f-d6744a1cba31','/admin:update','2026-09-18 15:34:52'),(153,'caea986b-a101-448e-ac5f-d6744a1cba31','/admin/announcements:view','2026-09-18 15:34:52'),(154,'caea986b-a101-448e-ac5f-d6744a1cba31','/admin/announcements:create','2026-09-18 15:34:52'),(155,'caea986b-a101-448e-ac5f-d6744a1cba31','/admin/announcements:update','2026-09-18 15:34:52'),(156,'caea986b-a101-448e-ac5f-d6744a1cba31','/admin/announcements:delete','2026-09-18 15:34:52'),(157,'caea986b-a101-448e-ac5f-d6744a1cba31','/admin/blog-categories:view','2026-09-18 15:34:52'),(158,'caea986b-a101-448e-ac5f-d6744a1cba31','/admin/blog-categories:create','2026-09-18 15:34:52'),(159,'caea986b-a101-448e-ac5f-d6744a1cba31','/admin/blog-categories:update','2026-09-18 15:34:52'),(160,'caea986b-a101-448e-ac5f-d6744a1cba31','/admin/blog-categories:delete','2026-09-18 15:34:52'),(161,'caea986b-a101-448e-ac5f-d6744a1cba31','/admin/blogs:view','2026-09-18 15:34:52'),(162,'caea986b-a101-448e-ac5f-d6744a1cba31','/admin/blogs:create','2026-09-18 15:34:52'),(163,'caea986b-a101-448e-ac5f-d6744a1cba31','/admin/blogs:update','2026-09-18 15:34:52'),(164,'caea986b-a101-448e-ac5f-d6744a1cba31','/admin/blogs:delete','2026-09-18 15:34:52'),(165,'caea986b-a101-448e-ac5f-d6744a1cba31','/admin/categories:view','2026-09-18 15:34:52'),(166,'caea986b-a101-448e-ac5f-d6744a1cba31','/admin/categories:create','2026-09-18 15:34:52'),(167,'caea986b-a101-448e-ac5f-d6744a1cba31','/admin/categories:update','2026-09-18 15:34:52'),(168,'caea986b-a101-448e-ac5f-d6744a1cba31','/admin/categories:delete','2026-09-18 15:34:52'),(169,'caea986b-a101-448e-ac5f-d6744a1cba31','/admin/coupons:view','2026-09-18 15:34:52'),(170,'caea986b-a101-448e-ac5f-d6744a1cba31','/admin/coupons:create','2026-09-18 15:34:52'),(171,'caea986b-a101-448e-ac5f-d6744a1cba31','/admin/coupons:update','2026-09-18 15:34:52'),(172,'caea986b-a101-448e-ac5f-d6744a1cba31','/admin/coupons:delete','2026-09-18 15:34:52'),(173,'caea986b-a101-448e-ac5f-d6744a1cba31','/admin/customers:view','2026-09-18 15:34:52'),(174,'caea986b-a101-448e-ac5f-d6744a1cba31','/admin/customers:update','2026-09-18 15:34:52'),(175,'caea986b-a101-448e-ac5f-d6744a1cba31','/admin/customers:delete','2026-09-18 15:34:52'),(176,'caea986b-a101-448e-ac5f-d6744a1cba31','/admin/member-logs:view','2026-09-18 15:34:52'),(177,'caea986b-a101-448e-ac5f-d6744a1cba31','/admin/messages:view','2026-09-18 15:34:52'),(178,'caea986b-a101-448e-ac5f-d6744a1cba31','/admin/messages:update','2026-09-18 15:34:52'),(179,'caea986b-a101-448e-ac5f-d6744a1cba31','/admin/messages:delete','2026-09-18 15:34:52'),(180,'caea986b-a101-448e-ac5f-d6744a1cba31','/admin/orders:view','2026-09-18 15:34:52'),(181,'caea986b-a101-448e-ac5f-d6744a1cba31','/admin/orders:update','2026-09-18 15:34:52'),(182,'caea986b-a101-448e-ac5f-d6744a1cba31','/admin/product-attributes:view','2026-09-18 15:34:52'),(183,'caea986b-a101-448e-ac5f-d6744a1cba31','/admin/product-attributes:create','2026-09-18 15:34:52'),(184,'caea986b-a101-448e-ac5f-d6744a1cba31','/admin/product-attributes:update','2026-09-18 15:34:52'),(185,'caea986b-a101-448e-ac5f-d6744a1cba31','/admin/product-attributes:delete','2026-09-18 15:34:52'),(186,'caea986b-a101-448e-ac5f-d6744a1cba31','/admin/products:view','2026-09-18 15:34:52'),(187,'caea986b-a101-448e-ac5f-d6744a1cba31','/admin/products:create','2026-09-18 15:34:52'),(188,'caea986b-a101-448e-ac5f-d6744a1cba31','/admin/products:update','2026-09-18 15:34:52'),(189,'caea986b-a101-448e-ac5f-d6744a1cba31','/admin/products:delete','2026-09-18 15:34:52'),(190,'caea986b-a101-448e-ac5f-d6744a1cba31','/admin/reviews:view','2026-09-18 15:34:52'),(191,'caea986b-a101-448e-ac5f-d6744a1cba31','/admin/reviews:update','2026-09-18 15:34:52'),(192,'caea986b-a101-448e-ac5f-d6744a1cba31','/admin/reviews:delete','2026-09-18 15:34:52'),(193,'caea986b-a101-448e-ac5f-d6744a1cba31','/admin/subscribers:view','2026-09-18 15:34:52'),(194,'caea986b-a101-448e-ac5f-d6744a1cba31','/admin/subscribers:update','2026-09-18 15:34:52'),(195,'caea986b-a101-448e-ac5f-d6744a1cba31','/admin/subscribers:delete','2026-09-18 15:34:52');
/*!40000 ALTER TABLE `admin_role_permissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `admin_roles`
--

DROP TABLE IF EXISTS `admin_roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `admin_roles` (
  `id` varchar(36) NOT NULL,
  `name` varchar(64) NOT NULL,
  `code` varchar(32) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `isSystem` tinyint(1) NOT NULL DEFAULT '0',
  `sortOrder` int NOT NULL DEFAULT '0',
  `createdAt` timestamp NOT NULL DEFAULT (now()),
  `updatedAt` timestamp NOT NULL DEFAULT (now()) ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `admin_roles_code_unique` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `admin_roles`
--

LOCK TABLES `admin_roles` WRITE;
/*!40000 ALTER TABLE `admin_roles` DISABLE KEYS */;
INSERT INTO `admin_roles` VALUES ('2ce8b5c5-6b24-477f-8f22-526c421f2aca','超级管理员','super_admin','拥有全部菜单权限，可管理管理员与角色；内置角色不可删除',1,0,'2026-09-18 15:09:20','2026-09-18 15:09:20'),('85402eb0-c874-4920-9304-226e326437a2','测试员','role_f8031567','测试员 demo体验官',0,100,'2026-09-18 15:22:00','2026-09-18 15:28:47'),('caea986b-a101-448e-ac5f-d6744a1cba31','普通管理员','admin','默认拥有「系统」分组以外的全部菜单权限，可按需调整',1,10,'2026-09-18 15:09:20','2026-09-18 15:09:20');
/*!40000 ALTER TABLE `admin_roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `admin_users`
--

DROP TABLE IF EXISTS `admin_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `admin_users` (
  `id` varchar(36) NOT NULL,
  `userId` varchar(36) NOT NULL,
  `roleId` varchar(36) NOT NULL,
  `displayName` varchar(64) DEFAULT NULL,
  `status` varchar(16) NOT NULL DEFAULT 'active',
  `remark` varchar(255) DEFAULT NULL,
  `lastLoginAt` timestamp NULL DEFAULT NULL,
  `createdAt` timestamp NOT NULL DEFAULT (now()),
  `updatedAt` timestamp NOT NULL DEFAULT (now()) ON UPDATE CURRENT_TIMESTAMP,
  `chatNickname` varchar(64) DEFAULT NULL,
  `chatAvatarUrl` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `admin_users_userId_unique` (`userId`),
  KEY `idx_admin_users_roleId` (`roleId`),
  CONSTRAINT `admin_users_roleId_admin_roles_id_fk` FOREIGN KEY (`roleId`) REFERENCES `admin_roles` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `admin_users_userId_user_id_fk` FOREIGN KEY (`userId`) REFERENCES `user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `admin_users`
--

LOCK TABLES `admin_users` WRITE;
/*!40000 ALTER TABLE `admin_users` DISABLE KEYS */;
INSERT INTO `admin_users` VALUES ('2933ad3a-fa4f-45cf-91bf-11e736e3e308','rXi36d6MyI8p0fn8rRhZwMiR5GGA7SVT','caea986b-a101-448e-ac5f-d6744a1cba31','Test Admin','active',NULL,'2026-09-18 15:09:37','2026-09-18 15:09:20','2026-09-18 15:36:55',NULL,NULL),('6d1c9ca7-3492-42af-b5e5-8533feb4c3a3','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6','2ce8b5c5-6b24-477f-8f22-526c421f2aca','Admin','active',NULL,'2026-09-19 13:59:26','2026-09-18 15:09:20','2026-09-19 13:59:25',NULL,NULL),('d2b5d298-a5fd-4a86-b497-bd5c768b6c2f','79UhVSTRB4Oh5ibyIoJfR2JqvkI5NXdb','85402eb0-c874-4920-9304-226e326437a2','test','active','demo体验官','2026-09-19 14:18:42','2026-09-18 15:29:22','2026-09-19 14:18:42',NULL,NULL);
/*!40000 ALTER TABLE `admin_users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `announcements`
--

DROP TABLE IF EXISTS `announcements`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `announcements` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(200) NOT NULL,
  `titleEn` varchar(200) DEFAULT NULL,
  `status` enum('active','inactive') NOT NULL DEFAULT 'active',
  `sortOrder` int NOT NULL DEFAULT '0',
  `startAt` timestamp NULL DEFAULT NULL,
  `endAt` timestamp NULL DEFAULT NULL,
  `createdAt` timestamp NOT NULL DEFAULT (now()),
  `updatedAt` timestamp NOT NULL DEFAULT (now()) ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_announcements_status_sort` (`status`,`sortOrder`),
  KEY `idx_announcements_created` (`createdAt`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `announcements`
--

LOCK TABLES `announcements` WRITE;
/*!40000 ALTER TABLE `announcements` DISABLE KEYS */;
INSERT INTO `announcements` VALUES (4,'全场满 $99 免运费','Free shipping on order over $99','active',0,NULL,NULL,'2026-09-17 17:24:08','2026-09-17 17:24:08'),(5,'绿色星期日促销：购买 5 盒雾化芯、烟弹或烟油，赠 1 瓶烟油','Take advantage of our green sunday promotion! Purchase 5 packs of coils, pods, or juices and receive 1 juice for free','active',1,NULL,NULL,'2026-09-17 17:24:08','2026-09-17 17:24:08');
/*!40000 ALTER TABLE `announcements` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `blogCategories`
--

DROP TABLE IF EXISTS `blogCategories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `blogCategories` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `nameEn` varchar(100) DEFAULT NULL,
  `slug` varchar(120) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `descriptionEn` varchar(255) DEFAULT NULL,
  `sortOrder` int NOT NULL DEFAULT '0',
  `createdAt` timestamp NOT NULL DEFAULT (now()),
  `updatedAt` timestamp NOT NULL DEFAULT (now()) ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `blogCategories_slug_unique` (`slug`),
  KEY `idx_blogCategories_sortOrder` (`sortOrder`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `blogCategories`
--

LOCK TABLES `blogCategories` WRITE;
/*!40000 ALTER TABLE `blogCategories` DISABLE KEYS */;
INSERT INTO `blogCategories` VALUES (1,'时尚穿搭','Fashion','fashion','穿搭灵感、材质与场景建议','Outfit inspiration, fabrics and styling for every occasion',1,'2026-09-17 13:05:03','2026-09-17 13:05:03'),(2,'选购指南','Buying Guides','guides','按需求挑选合适的单品与配件','How to pick the right pieces and accessories for your needs',2,'2026-09-17 13:05:03','2026-09-17 13:05:03'),(3,'品牌动态','Brand News','news','上新、活动与品牌消息','New arrivals, campaigns and brand updates',3,'2026-09-17 13:05:03','2026-09-17 13:05:03');
/*!40000 ALTER TABLE `blogCategories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `blogs`
--

DROP TABLE IF EXISTS `blogs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `blogs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `categoryId` int DEFAULT NULL,
  `title` varchar(200) NOT NULL,
  `titleEn` varchar(200) DEFAULT NULL,
  `slug` varchar(220) NOT NULL,
  `excerpt` varchar(300) DEFAULT NULL,
  `excerptEn` varchar(300) DEFAULT NULL,
  `content` json NOT NULL DEFAULT (_utf8mb4'[]'),
  `contentEn` json DEFAULT NULL,
  `coverImage` varchar(255) DEFAULT NULL,
  `author` varchar(100) NOT NULL DEFAULT 'uilines',
  `tags` json NOT NULL DEFAULT (_utf8mb4'[]'),
  `tagsEn` json DEFAULT NULL,
  `status` enum('draft','published','archived') NOT NULL DEFAULT 'draft',
  `publishedAt` timestamp NULL DEFAULT NULL,
  `createdAt` timestamp NOT NULL DEFAULT (now()),
  `updatedAt` timestamp NOT NULL DEFAULT (now()) ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `blogs_slug_unique` (`slug`),
  KEY `idx_blogs_status_publishedAt` (`status`,`publishedAt`),
  KEY `idx_blogs_title` (`title`),
  KEY `idx_blogs_category_status_publishedAt` (`categoryId`,`status`,`publishedAt`),
  CONSTRAINT `blogs_categoryId_blogCategories_id_fk` FOREIGN KEY (`categoryId`) REFERENCES `blogCategories` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `blogs`
--

LOCK TABLES `blogs` WRITE;
/*!40000 ALTER TABLE `blogs` DISABLE KEYS */;
INSERT INTO `blogs` VALUES (1,1,'女孩出行穿搭指南','Travel Dress Guide for Girls','travel-dress-guide-for-girls','从面料到版型，五个要点帮你挑到出行路上最舒服的那条连衣裙。','From fabric to fit, five essentials for choosing the perfect travel dress.','[{\"text\": \"说到出行，舒适与风格是必须同时考虑的两个因素，对经常在路上的女孩尤其如此。选对一条出行连衣裙，能让整段旅程轻松不少。下面这五个要点，帮你在挑选时少走弯路。\", \"type\": \"p\"}, {\"text\": \"1. 面料优先：选择透气且抗皱的材质\", \"type\": \"h2\"}, {\"text\": \"优先选择棉、亚麻或吸湿排汗混纺等透气面料，长时间飞行或观光时也能保持凉爽舒适。同时，抗皱面料能让你在整个旅程中都保持清爽利落的状态。\", \"type\": \"p\"}, {\"text\": \"2. 百搭是关键：可正式也可休闲\", \"type\": \"h2\"}, {\"text\": \"挑选只需更换配饰就能从白天过渡到夜晚的款式：搭配高跟鞋与首饰可以出席晚餐，换上运动鞋就能轻松逛街。这样的百搭单品最适合旅行。\", \"type\": \"p\"}, {\"text\": \"3. 关注气候：按天气准备合适的裙子\", \"type\": \"h2\"}, {\"text\": \"挑选出行连衣裙时要留意目的地气候：前往炎热的度假地可准备轻薄飘逸的款式，较冷地区则选择长袖或针织连衣裙。叠穿单品也能应对多变的天气。\", \"type\": \"p\"}, {\"text\": \"4. 轻装出行：选择容易混搭的款式\", \"type\": \"h2\"}, {\"text\": \"想最大化利用行李空间，就选能和出行衣橱中其它单品自由混搭的款式。中性色与经典廓形是不错的选择，搭配不同配饰即可变化出多种造型。\", \"type\": \"p\"}, {\"text\": \"5. 舒适不可妥协：优先考虑活动自如\", \"type\": \"h2\"}, {\"text\": \"无论是在拥挤的机场穿行，还是徒步探索新目的地，都要确保连衣裙便于活动。选择带弹力或宽松版型的款式，让整段旅程都保持舒适。\", \"type\": \"p\"}, {\"text\": \"把这几个要点记在心里，你就能整理出一份既时髦又实用的出行连衣裙清单。祝你旅途愉快！\", \"type\": \"p\"}]','[{\"text\": \"When it comes to traveling, comfort and style are key factors to consider, especially for girls on the go. Finding the perfect travel dress can make all the difference in your journey. Let\'s explore the essential factors to keep in mind when choosing the ideal travel dress.\", \"type\": \"p\"}, {\"text\": \"1. Fabric Matters: Choose Breathable and Wrinkle-Resistant Materials\", \"type\": \"h2\"}, {\"text\": \"Opt for dresses made from breathable fabrics like cotton, linen, or moisture-wicking blends to keep you cool and comfortable during long flights or sightseeing tours. Additionally, selecting wrinkle-resistant materials will help you look fresh and put-together throughout your travels.\", \"type\": \"p\"}, {\"text\": \"2. Versatility is Key: Select Dresses that can be Dressed Up or Down\", \"type\": \"h2\"}, {\"text\": \"Look for dresses that can easily transition from day to night with a simple change of accessories. Versatile pieces that can be dressed up with heels and jewelry for a dinner out or dressed down with sneakers for a casual day of exploring are ideal for travel.\", \"type\": \"p\"}, {\"text\": \"3. Consider the Climate: Pack Appropriate Dresses for the Weather\", \"type\": \"h2\"}, {\"text\": \"Be mindful of the destination\'s climate when selecting your travel dresses. Pack lightweight and breezy dresses for warm tropical destinations and opt for long-sleeved or sweater dresses for cooler climates. Layering pieces can also come in handy for unpredictable weather.\", \"type\": \"p\"}, {\"text\": \"4. Pack Light: Choose Dresses that are Easy to Mix and Match\", \"type\": \"h2\"}, {\"text\": \"Maximize your luggage space by selecting dresses that can be mixed and matched with other items in your travel wardrobe. Neutral colors and classic silhouettes are great choices as they can be paired with different accessories to create multiple looks.\", \"type\": \"p\"}, {\"text\": \"5. Comfort is Non-Negotiable: Prioritize Dresses that Allow for Movement\", \"type\": \"h2\"}, {\"text\": \"Ensure that your travel dress allows for ease of movement, whether you\'re navigating through crowded airports or exploring new destinations on foot. Opt for dresses with stretch or relaxed fits to stay comfortable throughout your journey.\", \"type\": \"p\"}, {\"text\": \"By keeping these essential factors in mind, you can curate a travel dress collection that is not only stylish but also practical and versatile for all your adventures. Happy travels!\", \"type\": \"p\"}]','/images/blog/travel-dress.jpg','uilines','[\"旅行\"]','[\"Travel\"]','published','2025-02-13 09:00:00','2026-09-17 13:05:03','2026-09-17 13:05:03'),(2,1,'春季灵感穿搭','Outfits inspired by Spring','outfits-inspired-by-spring','轻盈的色彩与层叠搭配，把春天的松弛感穿在身上。','Light colours and easy layering to bring spring\'s ease into your wardrobe.','[{\"text\": \"春天最迷人的地方，是它允许你在同一天里体验两种温度。层叠搭配因此成为这个季节最实用的技巧：早晚保暖、午间透气，风格也随之变得更丰富。\", \"type\": \"p\"}, {\"text\": \"从色彩开始\", \"type\": \"h2\"}, {\"text\": \"把奶油白、浅杏、雾霾蓝这类柔和色调放在上半身，下半身保持中性色，整体会显得干净又轻盈。想更有层次，可以用同色系深浅叠穿。\", \"type\": \"p\"}, {\"text\": \"外套决定轮廓\", \"type\": \"h2\"}, {\"text\": \"薄款风衣或廓形西装是春季的万能外套：内搭基础款时它们负责造型感，内搭有设计感的单品时它们负责收拢线条。\", \"type\": \"p\"}]','[{\"text\": \"The best thing about spring is that it lets you experience two temperatures in a single day. That is why layering becomes the season\'s most practical technique: warm in the morning, breathable at noon, and richer in style.\", \"type\": \"p\"}, {\"text\": \"Start with colour\", \"type\": \"h2\"}, {\"text\": \"Keep soft tones such as cream, light apricot and misty blue on the top half, and neutral shades on the bottom for a clean, airy look. For more depth, layer different shades of the same colour.\", \"type\": \"p\"}, {\"text\": \"Let the outer layer set the silhouette\", \"type\": \"h2\"}, {\"text\": \"A light trench or oversized blazer is the season\'s most versatile outer layer: it adds shape over basics and frames more detailed pieces underneath.\", \"type\": \"p\"}]','/images/blog/spring-outfits.jpg','uilines','[\"春季\"]','[\"Spring\"]','published','2025-02-03 09:00:00','2026-09-17 13:05:03','2026-09-17 13:05:03'),(3,1,'沙滩包怎么选？','Looking to buy Beach Bag?','looking-to-buy-beach-bag','容量、材质与细节，挑选沙滩包的三个判断标准。','Capacity, material and details: three checks before you buy a beach bag.','[{\"text\": \"一只合适的沙滩包，要在容量、耐用和好搭之间取得平衡。选购前先想清楚你通常会带什么，再对照下面三点。\", \"type\": \"p\"}, {\"text\": \"容量按随身清单算\", \"type\": \"h2\"}, {\"text\": \"毛巾、水杯、防晒、换洗衣物——把这些常见物品叠放起来量一下，再选择比它略大一号的容量，避免过满导致肩带受力过大。\", \"type\": \"p\"}, {\"text\": \"材质决定寿命\", \"type\": \"h2\"}, {\"text\": \"防泼水涂层帆布或编织材质更适合海边环境，沙粒容易抖落、湿气也不易残留。内衬可拆洗的款式更省心。\", \"type\": \"p\"}]','[{\"text\": \"A good beach bag balances capacity, durability and easy styling. Before buying, decide what you usually carry, then check the three points below.\", \"type\": \"p\"}, {\"text\": \"Size it against your packing list\", \"type\": \"h2\"}, {\"text\": \"Stack the usual items - towel, bottle, sunscreen, a change of clothes - and measure them. Choose a bag one size larger so the straps never take the full weight of an overstuffed load.\", \"type\": \"p\"}, {\"text\": \"Material decides how long it lasts\", \"type\": \"h2\"}, {\"text\": \"Water-repellent canvas or woven materials suit the seaside better: sand shakes out and moisture does not linger. A removable, washable lining makes life easier.\", \"type\": \"p\"}]','/images/blog/beach-bag.jpg','uilines','[\"包袋\"]','[\"Bags\"]','published','2025-01-22 09:00:00','2026-09-17 13:05:03','2026-09-17 13:05:03'),(4,1,'节日季该穿什么颜色','Colours to wear in festive season','colours-to-wear-in-festive-season','不必全身撞色，用小面积亮色点亮节日造型。','You do not need head-to-toe colour - brighten festive looks with small accents.','[{\"text\": \"节日造型的关键不是颜色越多越好，而是让颜色出现在对的位置。整套中性色加一处亮色，往往比全身高饱和更耐看。\", \"type\": \"p\"}, {\"text\": \"把亮色放在上半身\", \"type\": \"h2\"}, {\"text\": \"靠近脸部的高饱和色能让气色更好，也更容易在合影中出彩。下装保持深色，整体重心稳定。\", \"type\": \"p\"}, {\"text\": \"配饰是低成本的尝试\", \"type\": \"h2\"}, {\"text\": \"如果还不确定是否适合某种颜色，先用围巾、包袋或鞋履试水，与日常造型搭配一周后再考虑大面积单品。\", \"type\": \"p\"}]','[{\"text\": \"The key to a festive outfit is not how many colours you wear, but where they appear. Neutrals with one bright accent often look better than head-to-toe saturation.\", \"type\": \"p\"}, {\"text\": \"Keep bright colours up top\", \"type\": \"h2\"}, {\"text\": \"A saturated colour near the face brightens your complexion and reads well in photos. Keep the bottom half dark to anchor the look.\", \"type\": \"p\"}, {\"text\": \"Accessories are a low-risk trial\", \"type\": \"h2\"}, {\"text\": \"If you are unsure about a colour, test it with a scarf, bag or shoes first. Wear it with your everyday outfits for a week before committing to a larger piece.\", \"type\": \"p\"}]','/images/blog/festive-colours.jpg','uilines','[\"节日\"]','[\"Festive\"]','published','2025-01-15 09:00:00','2026-09-17 13:05:03','2026-09-17 13:05:03'),(5,1,'第一次约会穿什么','What to wear on a first date','what-to-wear-on-a-first-date','舒适高于一切：一套让你自在的搭配，才是最好的状态。','Comfort first: the best outfit is the one you feel at ease in.','[{\"text\": \"第一次约会穿什么，与其纠结风格，不如先问自己一个问题：这套衣服我会不会一直想去调整它？合身与舒适，永远比时髦更重要。\", \"type\": \"p\"}, {\"text\": \"按场景选，而不是按风格选\", \"type\": \"h2\"}, {\"text\": \"咖啡厅、展览、晚餐对鞋履与材质的要求完全不同。先确定行程，再决定是针织上衣配直筒裤，还是连衣裙配平底鞋。\", \"type\": \"p\"}, {\"text\": \"留一件熟悉的单品\", \"type\": \"h2\"}, {\"text\": \"把常穿、确定好看的单品作为基础，再尝试一个新元素：新的颜色、新的配饰或新的廓形。这样既有新鲜感，也不会冒险。\", \"type\": \"p\"}]','[{\"text\": \"Rather than agonising over style, ask one question before a first date: will I keep wanting to adjust this outfit? Fit and comfort matter more than trends.\", \"type\": \"p\"}, {\"text\": \"Choose for the plan, not for the style\", \"type\": \"h2\"}, {\"text\": \"A coffee shop, an exhibition and dinner call for very different shoes and fabrics. Decide on the plan first, then pick a knit with straight trousers or a dress with flats.\", \"type\": \"p\"}, {\"text\": \"Keep one piece you already trust\", \"type\": \"h2\"}, {\"text\": \"Build on something you wear often and know works, then add one new element: a colour, an accessory or a silhouette. It feels fresh without the risk.\", \"type\": \"p\"}]','/images/blog/first-date.jpg','uilines','[\"约会\"]','[\"Date\"]','published','2025-01-08 09:00:00','2026-09-17 13:05:03','2026-09-17 13:05:03'),(6,2,'男士热门 T 恤清单','Top Trending T-Shirt for Men','top-trending-t-shirt-for-men','克重、领型与版型：三分钟看懂 T 恤的挑选逻辑。','Weight, neckline and fit: how to choose a T-shirt in three minutes.','[{\"text\": \"T 恤的差别往往藏在参数里。了解克重、领型与版型这三项，就足以在众多款式里快速筛掉不合适的选项。\", \"type\": \"p\"}, {\"text\": \"克重决定质感\", \"type\": \"h2\"}, {\"text\": \"180g 左右适合夏季单穿，轻薄透气；220g 以上更挺括，适合外穿或作为内搭支撑廓形。\", \"type\": \"p\"}, {\"text\": \"领型影响脸型比例\", \"type\": \"h2\"}, {\"text\": \"圆领最百搭，适合大多数场合；V 领能拉长颈部线条，但领口不要太深；小立领更利落，适合搭配外套。\", \"type\": \"p\"}, {\"text\": \"版型看肩线\", \"type\": \"h2\"}, {\"text\": \"肩缝应刚好落在肩点：偏内显得局促，偏外会显松垮。下摆长度以盖住腰带三分之一为佳。\", \"type\": \"p\"}]','[{\"text\": \"The difference between T-shirts often hides in the spec sheet. Understanding weight, neckline and fit is enough to filter out the wrong options quickly.\", \"type\": \"p\"}, {\"text\": \"Fabric weight sets the feel\", \"type\": \"h2\"}, {\"text\": \"Around 180g is ideal for wearing alone in summer: light and breathable. Above 220g feels more structured and works well over a base layer.\", \"type\": \"p\"}, {\"text\": \"The neckline changes your proportions\", \"type\": \"h2\"}, {\"text\": \"A crew neck is the most versatile choice for most occasions. A V-neck lengthens the neck line - keep the depth modest. A short stand collar looks sharper under a jacket.\", \"type\": \"p\"}, {\"text\": \"Judge the fit by the shoulder seam\", \"type\": \"h2\"}, {\"text\": \"The seam should sit right on the shoulder point: too far in feels tight, too far out looks sloppy. A hem that covers about a third of the waistband is a good length.\", \"type\": \"p\"}]','/images/blog/mens-tshirt.jpg','uilines','[\"男士\"]','[\"Men\"]','published','2025-01-01 09:00:00','2026-09-17 13:05:03','2026-09-17 13:05:03');
/*!40000 ALTER TABLE `blogs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cartItems`
--

DROP TABLE IF EXISTS `cartItems`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cartItems` (
  `id` int NOT NULL AUTO_INCREMENT,
  `userId` varchar(36) NOT NULL,
  `productId` int NOT NULL,
  `qty` int NOT NULL DEFAULT '1',
  `attributes` json DEFAULT NULL,
  `createdAt` timestamp NOT NULL DEFAULT (now()),
  `updatedAt` timestamp NOT NULL DEFAULT (now()) ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_cartItems_user_product` (`userId`,`productId`),
  KEY `cartItems_productId_products_id_fk` (`productId`),
  CONSTRAINT `cartItems_productId_products_id_fk` FOREIGN KEY (`productId`) REFERENCES `products` (`id`) ON DELETE CASCADE,
  CONSTRAINT `cartItems_userId_user_id_fk` FOREIGN KEY (`userId`) REFERENCES `user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=764 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cartItems`
--

LOCK TABLES `cartItems` WRITE;
/*!40000 ALTER TABLE `cartItems` DISABLE KEYS */;
INSERT INTO `cartItems` VALUES (759,'MtTk43nCRWicn9XwqYobCc2DIU2uqbI6',25,2,NULL,'2026-09-18 21:38:25','2026-09-18 21:38:25');
/*!40000 ALTER TABLE `cartItems` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `categories`
--

DROP TABLE IF EXISTS `categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `categories` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `slug` varchar(120) NOT NULL,
  `sortOrder` int NOT NULL DEFAULT '0',
  `createdAt` timestamp NOT NULL DEFAULT (now()),
  `updatedAt` timestamp NOT NULL DEFAULT (now()) ON UPDATE CURRENT_TIMESTAMP,
  `nameEn` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `categories_slug_unique` (`slug`)
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `categories`
--

LOCK TABLES `categories` WRITE;
/*!40000 ALTER TABLE `categories` DISABLE KEYS */;
INSERT INTO `categories` VALUES (13,'电子烟套装','vape-kits',1,'2026-09-16 12:35:02','2026-09-17 14:05:38','Vape Kits'),(14,'烟油','e-liquids',2,'2026-09-16 12:35:02','2026-09-16 12:35:02','E-Liquids'),(15,'一次性电子烟','disposable-vape',3,'2026-09-16 12:35:02','2026-09-16 12:35:02','Disposable Vape'),(16,'调味烟油','flavored-juice',4,'2026-09-16 12:35:02','2026-09-16 12:35:02','Flavored Juice'),(17,'雾化芯','vape-coils',5,'2026-09-16 12:35:02','2026-09-16 12:35:02','Vape Coils'),(18,'烟弹套装','pod-kits',6,'2026-09-16 12:35:02','2026-09-16 12:35:02','Pod Kits');
/*!40000 ALTER TABLE `categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `chat_conversations`
--

DROP TABLE IF EXISTS `chat_conversations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `chat_conversations` (
  `id` int NOT NULL AUTO_INCREMENT,
  `conversationKey` varchar(80) NOT NULL,
  `userId` varchar(36) DEFAULT NULL,
  `visitorId` varchar(64) DEFAULT NULL,
  `visitCode` varchar(8) DEFAULT NULL,
  `displayName` varchar(100) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `kind` varchar(16) NOT NULL DEFAULT 'visitor',
  `status` varchar(16) NOT NULL DEFAULT 'open',
  `lastMessageAt` timestamp NOT NULL DEFAULT (now()),
  `lastMessagePreview` varchar(200) DEFAULT NULL,
  `lastMessageFrom` varchar(16) DEFAULT NULL,
  `adminUnread` int NOT NULL DEFAULT '0',
  `visitorUnread` int NOT NULL DEFAULT '0',
  `ip` varchar(45) DEFAULT NULL,
  `country` varchar(64) DEFAULT NULL,
  `userAgent` varchar(255) DEFAULT NULL,
  `createdAt` timestamp NOT NULL DEFAULT (now()),
  `updatedAt` timestamp NOT NULL DEFAULT (now()) ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `chat_conversations_conversationKey_unique` (`conversationKey`),
  KEY `idx_chat_conv_last_msg` (`lastMessageAt`),
  KEY `idx_chat_conv_status_last` (`status`,`lastMessageAt`),
  KEY `idx_chat_conv_user` (`userId`),
  CONSTRAINT `chat_conversations_userId_user_id_fk` FOREIGN KEY (`userId`) REFERENCES `user` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chat_conversations`
--

LOCK TABLES `chat_conversations` WRITE;
/*!40000 ALTER TABLE `chat_conversations` DISABLE KEYS */;
INSERT INTO `chat_conversations` VALUES (1,'visitor:5e56acc5e21a48e2a7a11f8664d17abf',NULL,'5e56acc5e21a48e2a7a11f8664d17abf','U9L9V','访客',NULL,'visitor','open','2026-09-20 14:09:43','You\'re now connected to our support team — feel free to ask anything.','admin',0,0,'183.223.133.201',NULL,'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36','2026-09-20 14:09:43','2026-09-20 14:09:43');
/*!40000 ALTER TABLE `chat_conversations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `chat_messages`
--

DROP TABLE IF EXISTS `chat_messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `chat_messages` (
  `id` int NOT NULL AUTO_INCREMENT,
  `conversationId` int NOT NULL,
  `senderType` varchar(16) NOT NULL,
  `adminUserId` varchar(36) DEFAULT NULL,
  `senderName` varchar(100) DEFAULT NULL,
  `body` text NOT NULL,
  `createdAt` timestamp NOT NULL DEFAULT (now()),
  PRIMARY KEY (`id`),
  KEY `chat_messages_adminUserId_user_id_fk` (`adminUserId`),
  KEY `idx_chat_msg_conv_id` (`conversationId`,`id`),
  KEY `idx_chat_msg_created` (`createdAt`),
  CONSTRAINT `chat_messages_adminUserId_user_id_fk` FOREIGN KEY (`adminUserId`) REFERENCES `user` (`id`) ON DELETE SET NULL,
  CONSTRAINT `chat_messages_conversationId_chat_conversations_id_fk` FOREIGN KEY (`conversationId`) REFERENCES `chat_conversations` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chat_messages`
--

LOCK TABLES `chat_messages` WRITE;
/*!40000 ALTER TABLE `chat_messages` DISABLE KEYS */;
INSERT INTO `chat_messages` VALUES (1,1,'admin',NULL,NULL,'Hi! Welcome to UiLines. How can we help you today?','2026-09-20 14:09:42'),(2,1,'admin',NULL,NULL,'You\'re now connected to our support team — feel free to ask anything.','2026-09-20 14:09:43');
/*!40000 ALTER TABLE `chat_messages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `contactMessages`
--

DROP TABLE IF EXISTS `contactMessages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `contactMessages` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `email` varchar(255) NOT NULL,
  `phone` varchar(32) DEFAULT NULL,
  `subject` varchar(200) DEFAULT NULL,
  `message` text NOT NULL,
  `status` enum('new','contacted','closed') NOT NULL DEFAULT 'new',
  `followUpNote` text,
  `followedUpAt` timestamp NULL DEFAULT NULL,
  `handledBy` varchar(255) DEFAULT NULL,
  `sourceUrl` varchar(255) DEFAULT NULL,
  `createdAt` timestamp NOT NULL DEFAULT (now()),
  `updatedAt` timestamp NOT NULL DEFAULT (now()) ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_contact_status_created` (`status`,`createdAt`),
  KEY `idx_contact_email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `contactMessages`
--

LOCK TABLES `contactMessages` WRITE;
/*!40000 ALTER TABLE `contactMessages` DISABLE KEYS */;
INSERT INTO `contactMessages` VALUES (5,'Alice Wong','alice@example.com','+44 20 7946 0018','Bulk order inquiry','Hi, I would like to order 200 units for our retail store. Could you send a quotation with shipping to London?','new',NULL,NULL,NULL,'/en/contact','2026-09-17 17:08:36','2026-09-17 17:08:36'),(7,'Daniel Roberts','daniel@example.com','+1 415 555 0132','Where is my order?','My order was placed 6 days ago and the tracking has not updated yet. Could you check it for me?','contacted','已电话回访：包裹在转运中心，预计 2 个工作日内派送，客户接受。','2026-09-17 17:24:13','admin@uilines.dev','/en/contact','2026-09-17 17:24:13','2026-09-17 17:24:13');
/*!40000 ALTER TABLE `contactMessages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `couponRedemptions`
--

DROP TABLE IF EXISTS `couponRedemptions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `couponRedemptions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `couponId` int NOT NULL,
  `userId` varchar(36) NOT NULL,
  `orderId` int NOT NULL,
  `discountCents` int NOT NULL,
  `createdAt` timestamp NOT NULL DEFAULT (now()),
  PRIMARY KEY (`id`),
  KEY `idx_couponRedemptions_coupon_user` (`couponId`,`userId`),
  KEY `idx_couponRedemptions_orderId` (`orderId`),
  CONSTRAINT `couponRedemptions_couponId_coupons_id_fk` FOREIGN KEY (`couponId`) REFERENCES `coupons` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `couponRedemptions`
--

LOCK TABLES `couponRedemptions` WRITE;
/*!40000 ALTER TABLE `couponRedemptions` DISABLE KEYS */;
INSERT INTO `couponRedemptions` VALUES (1,1,'rshOAV8G58SmzJy7wRZlnt436PoxqxbJ',1,600,'2026-09-17 14:07:18');
/*!40000 ALTER TABLE `couponRedemptions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `coupons`
--

DROP TABLE IF EXISTS `coupons`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `coupons` (
  `id` int NOT NULL AUTO_INCREMENT,
  `code` varchar(32) NOT NULL,
  `type` enum('percent','fixed') NOT NULL DEFAULT 'percent',
  `value` int NOT NULL DEFAULT '0',
  `minSubtotalCents` int NOT NULL DEFAULT '0',
  `maxDiscountCents` int DEFAULT NULL,
  `startsAt` timestamp NULL DEFAULT NULL,
  `endsAt` timestamp NULL DEFAULT NULL,
  `usageLimit` int DEFAULT NULL,
  `usedCount` int NOT NULL DEFAULT '0',
  `perUserLimit` int NOT NULL DEFAULT '1',
  `status` enum('active','disabled') NOT NULL DEFAULT 'active',
  `description` varchar(255) DEFAULT NULL,
  `descriptionEn` varchar(255) DEFAULT NULL,
  `createdAt` timestamp NOT NULL DEFAULT (now()),
  `updatedAt` timestamp NOT NULL DEFAULT (now()) ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `coupons_code_unique` (`code`),
  KEY `idx_coupons_status` (`status`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `coupons`
--

LOCK TABLES `coupons` WRITE;
/*!40000 ALTER TABLE `coupons` DISABLE KEYS */;
INSERT INTO `coupons` VALUES (1,'WELCOME10','percent',10,0,2000,NULL,NULL,NULL,0,1,'active','新客首单 9 折（最高 $20）','10% off your first order (up to $20)','2026-09-17 14:05:38','2026-09-17 14:33:40'),(2,'SAVE5','fixed',500,5000,NULL,NULL,NULL,NULL,0,3,'active','满 $50 立减 $5','$5 off orders over $50','2026-09-17 14:05:38','2026-09-17 14:05:38');
/*!40000 ALTER TABLE `coupons` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `dailyProductLikes`
--

DROP TABLE IF EXISTS `dailyProductLikes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `dailyProductLikes` (
  `id` int NOT NULL AUTO_INCREMENT,
  `statDate` date NOT NULL,
  `productId` int NOT NULL,
  `likeCount` int NOT NULL DEFAULT '0',
  `createdAt` timestamp NOT NULL DEFAULT (now()),
  `updatedAt` timestamp NOT NULL DEFAULT (now()) ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_dailyProductLikes_date_product` (`statDate`,`productId`),
  KEY `idx_dailyProductLikes_date` (`statDate`),
  KEY `idx_dailyProductLikes_product` (`productId`),
  CONSTRAINT `dailyProductLikes_productId_products_id_fk` FOREIGN KEY (`productId`) REFERENCES `products` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=369 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dailyProductLikes`
--

LOCK TABLES `dailyProductLikes` WRITE;
/*!40000 ALTER TABLE `dailyProductLikes` DISABLE KEYS */;
INSERT INTO `dailyProductLikes` VALUES (337,'2026-08-22',25,1,'2026-09-18 15:37:23','2026-09-18 15:37:23'),(338,'2026-08-23',30,1,'2026-09-18 15:37:23','2026-09-18 15:37:23'),(339,'2026-08-25',25,1,'2026-09-18 15:37:23','2026-09-18 15:37:23'),(340,'2026-08-26',31,1,'2026-09-18 15:37:23','2026-09-18 15:37:23'),(341,'2026-08-27',28,1,'2026-09-18 15:37:23','2026-09-18 15:37:23'),(342,'2026-08-28',25,1,'2026-09-18 15:37:23','2026-09-18 15:37:23'),(343,'2026-08-29',30,1,'2026-09-18 15:37:23','2026-09-18 15:37:23'),(344,'2026-08-30',27,1,'2026-09-18 15:37:23','2026-09-18 15:37:23'),(345,'2026-08-31',25,1,'2026-09-18 15:37:23','2026-09-18 15:37:23'),(346,'2026-09-01',26,1,'2026-09-18 15:37:23','2026-09-18 15:37:23'),(347,'2026-09-02',31,1,'2026-09-18 15:37:23','2026-09-18 15:37:23'),(348,'2026-09-03',30,1,'2026-09-18 15:37:23','2026-09-18 15:37:23'),(349,'2026-09-04',29,1,'2026-09-18 15:37:23','2026-09-18 15:37:23'),(350,'2026-09-05',25,1,'2026-09-18 15:37:23','2026-09-18 15:37:23'),(351,'2026-09-06',28,1,'2026-09-18 15:37:23','2026-09-18 15:37:23'),(352,'2026-09-07',31,1,'2026-09-18 15:37:23','2026-09-18 15:37:23'),(353,'2026-09-09',30,1,'2026-09-18 15:37:23','2026-09-18 15:37:23'),(354,'2026-09-11',32,1,'2026-09-18 15:37:23','2026-09-18 15:37:23'),(355,'2026-09-12',28,1,'2026-09-18 15:37:23','2026-09-18 15:37:23'),(356,'2026-09-13',25,1,'2026-09-18 15:37:23','2026-09-18 15:37:23'),(357,'2026-09-14',27,1,'2026-09-18 15:37:23','2026-09-18 15:37:23'),(358,'2026-09-15',31,1,'2026-09-18 15:37:23','2026-09-18 15:37:23'),(359,'2026-09-16',30,1,'2026-09-18 15:37:23','2026-09-18 15:37:23'),(360,'2026-09-17',26,1,'2026-09-18 15:37:23','2026-09-18 15:37:23'),(361,'2026-09-18',25,2,'2026-09-18 15:37:23','2026-09-18 15:37:23'),(362,'2026-09-18',30,2,'2026-09-18 15:37:23','2026-09-18 15:37:23'),(363,'2026-09-19',25,1,'2026-09-19 06:00:34','2026-09-19 06:00:34'),(364,'2026-09-19',26,1,'2026-09-19 06:00:34','2026-09-19 06:00:34'),(365,'2026-09-19',27,1,'2026-09-19 06:00:34','2026-09-19 06:00:34'),(366,'2026-09-19',28,1,'2026-09-19 06:00:34','2026-09-19 06:00:34'),(367,'2026-09-19',29,1,'2026-09-19 06:00:34','2026-09-19 06:00:34'),(368,'2026-09-19',31,1,'2026-09-19 06:00:34','2026-09-19 06:00:34');
/*!40000 ALTER TABLE `dailyProductLikes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `dailySalesStats`
--

DROP TABLE IF EXISTS `dailySalesStats`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `dailySalesStats` (
  `id` int NOT NULL AUTO_INCREMENT,
  `statDate` date NOT NULL,
  `orderCount` int NOT NULL DEFAULT '0',
  `paidOrderCount` int NOT NULL DEFAULT '0',
  `revenueCents` int NOT NULL DEFAULT '0',
  `createdAt` timestamp NOT NULL DEFAULT (now()),
  `updatedAt` timestamp NOT NULL DEFAULT (now()) ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `dailySalesStats_statDate_unique` (`statDate`),
  KEY `idx_dailySales_stats_date` (`statDate`)
) ENGINE=InnoDB AUTO_INCREMENT=483 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dailySalesStats`
--

LOCK TABLES `dailySalesStats` WRITE;
/*!40000 ALTER TABLE `dailySalesStats` DISABLE KEYS */;
INSERT INTO `dailySalesStats` VALUES (1,'2026-08-19',0,0,0,'2026-09-17 18:16:14','2026-09-17 18:16:14'),(2,'2026-08-20',0,0,0,'2026-09-17 18:16:14','2026-09-17 18:16:14'),(3,'2026-08-21',1,1,5000,'2026-09-17 18:16:14','2026-09-18 11:14:05'),(4,'2026-08-22',0,0,0,'2026-09-17 18:16:14','2026-09-17 18:16:14'),(5,'2026-08-23',0,0,0,'2026-09-17 18:16:14','2026-09-17 18:16:14'),(6,'2026-08-24',1,1,6700,'2026-09-17 18:16:14','2026-09-18 11:14:05'),(7,'2026-08-25',0,0,0,'2026-09-17 18:16:14','2026-09-17 18:16:14'),(8,'2026-08-26',0,0,0,'2026-09-17 18:16:14','2026-09-17 18:16:14'),(9,'2026-08-27',1,1,6000,'2026-09-17 18:16:14','2026-09-18 11:14:05'),(10,'2026-08-28',0,0,0,'2026-09-17 18:16:14','2026-09-17 18:16:14'),(11,'2026-08-29',0,0,0,'2026-09-17 18:16:14','2026-09-17 18:17:56'),(12,'2026-08-30',1,1,9000,'2026-09-17 18:16:14','2026-09-18 11:14:05'),(13,'2026-08-31',0,0,0,'2026-09-17 18:16:14','2026-09-17 18:16:14'),(14,'2026-09-01',1,1,2000,'2026-09-17 18:16:14','2026-09-18 11:14:05'),(15,'2026-09-02',0,0,0,'2026-09-17 18:16:14','2026-09-17 18:16:14'),(16,'2026-09-03',0,0,0,'2026-09-17 18:16:14','2026-09-17 18:16:14'),(17,'2026-09-04',1,1,7000,'2026-09-17 18:16:14','2026-09-18 11:14:05'),(18,'2026-09-05',0,0,0,'2026-09-17 18:16:14','2026-09-17 18:17:56'),(19,'2026-09-06',1,1,10000,'2026-09-17 18:16:14','2026-09-18 11:14:05'),(20,'2026-09-07',0,0,0,'2026-09-17 18:16:14','2026-09-17 18:16:14'),(21,'2026-09-08',1,1,2500,'2026-09-17 18:16:14','2026-09-18 11:14:05'),(22,'2026-09-09',0,0,0,'2026-09-17 18:16:14','2026-09-17 18:16:14'),(23,'2026-09-10',1,1,1000,'2026-09-17 18:16:14','2026-09-18 11:14:05'),(24,'2026-09-11',0,0,0,'2026-09-17 18:16:14','2026-09-17 18:17:56'),(25,'2026-09-12',1,1,3000,'2026-09-17 18:16:14','2026-09-18 11:14:05'),(26,'2026-09-13',0,0,0,'2026-09-17 18:16:14','2026-09-17 18:16:14'),(27,'2026-09-14',1,1,6700,'2026-09-17 18:16:14','2026-09-18 11:14:05'),(28,'2026-09-15',1,0,0,'2026-09-17 18:16:14','2026-09-18 11:14:05'),(29,'2026-09-16',1,1,5000,'2026-09-17 18:16:14','2026-09-18 11:14:05'),(30,'2026-09-17',2,0,0,'2026-09-17 18:16:14','2026-09-18 11:14:05'),(91,'2026-09-18',1,1,22200,'2026-09-18 09:54:08','2026-09-18 12:27:32'),(482,'2026-09-19',0,0,0,'2026-09-19 06:00:34','2026-09-19 06:00:34');
/*!40000 ALTER TABLE `dailySalesStats` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `memberLogs`
--

DROP TABLE IF EXISTS `memberLogs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `memberLogs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `userId` varchar(36) DEFAULT NULL,
  `email` varchar(255) NOT NULL,
  `event` enum('register','login') NOT NULL DEFAULT 'login',
  `ip` varchar(45) DEFAULT NULL,
  `country` varchar(64) DEFAULT NULL,
  `countryCode` varchar(8) DEFAULT NULL,
  `region` varchar(100) DEFAULT NULL,
  `city` varchar(100) DEFAULT NULL,
  `userAgent` varchar(500) DEFAULT NULL,
  `createdAt` timestamp NOT NULL DEFAULT (now()),
  PRIMARY KEY (`id`),
  KEY `idx_memberLogs_created` (`createdAt`),
  KEY `idx_memberLogs_user_created` (`userId`,`createdAt`),
  KEY `idx_memberLogs_event_created` (`event`,`createdAt`),
  KEY `idx_memberLogs_email` (`email`),
  CONSTRAINT `memberLogs_userId_user_id_fk` FOREIGN KEY (`userId`) REFERENCES `user` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=144 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `memberLogs`
--

LOCK TABLES `memberLogs` WRITE;
/*!40000 ALTER TABLE `memberLogs` DISABLE KEYS */;
INSERT INTO `memberLogs` VALUES (5,'MtTk43nCRWicn9XwqYobCc2DIU2uqbI6','admin@uilines.dev','login','::1',NULL,NULL,NULL,NULL,'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','2026-09-18 10:12:52'),(6,'MtTk43nCRWicn9XwqYobCc2DIU2uqbI6','admin@uilines.dev','login','::1',NULL,NULL,NULL,NULL,'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','2026-09-18 11:00:40'),(7,'MtTk43nCRWicn9XwqYobCc2DIU2uqbI6','admin@uilines.dev','login','::1',NULL,NULL,NULL,NULL,'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','2026-09-18 11:01:07'),(8,'demo-member-01','demo.member01@example.com','register','104.28.12.31','United States',NULL,NULL,'New York','seed/demo-profile','2026-06-30 11:05:42'),(9,'demo-member-02','demo.member02@example.com','register','104.28.13.7','United States',NULL,NULL,'Los Angeles','seed/demo-profile','2026-07-04 11:05:42'),(10,'demo-member-03','demo.member03@example.com','register','104.28.14.19','United States',NULL,NULL,'Chicago','seed/demo-profile','2026-07-08 11:05:42'),(11,'demo-member-04','demo.member04@example.com','register','104.28.15.44','United States',NULL,NULL,'Austin','seed/demo-profile','2026-07-12 11:05:42'),(12,'demo-member-05','demo.member05@example.com','register','133.130.20.11','日本',NULL,NULL,'东京','seed/demo-profile','2026-07-16 11:05:42'),(13,'demo-member-06','demo.member06@example.com','register','133.130.21.35','日本',NULL,NULL,'大阪','seed/demo-profile','2026-07-20 11:05:42'),(14,'demo-member-07','demo.member07@example.com','register','133.130.22.9','日本',NULL,NULL,'名古屋','seed/demo-profile','2026-07-24 11:05:42'),(15,'demo-member-08','demo.member08@example.com','register','85.214.10.23','Germany',NULL,NULL,'Berlin','seed/demo-profile','2026-07-28 11:05:42'),(16,'demo-member-09','demo.member09@example.com','register','85.214.11.56','Germany',NULL,NULL,'Munich','seed/demo-profile','2026-08-01 11:05:42'),(17,'demo-member-10','demo.member10@example.com','register','51.140.20.8','United Kingdom',NULL,NULL,'London','seed/demo-profile','2026-08-05 11:05:42'),(18,'demo-member-11','demo.member11@example.com','register','51.140.21.77','United Kingdom',NULL,NULL,'Manchester','seed/demo-profile','2026-08-09 11:05:42'),(19,'demo-member-12','demo.member12@example.com','register','92.222.30.14','France',NULL,NULL,'Paris','seed/demo-profile','2026-08-13 11:05:42'),(20,'demo-member-13','demo.member13@example.com','register','92.222.31.28','France',NULL,NULL,'Lyon','seed/demo-profile','2026-08-17 11:05:42'),(21,'demo-member-14','demo.member14@example.com','register','99.79.10.5','Canada',NULL,NULL,'Toronto','seed/demo-profile','2026-08-21 11:05:42'),(22,'demo-member-15','demo.member15@example.com','register','99.79.11.62','Canada',NULL,NULL,'Vancouver','seed/demo-profile','2026-08-25 11:05:42'),(23,'demo-member-16','demo.member16@example.com','register','13.236.20.19','Australia',NULL,NULL,'Sydney','seed/demo-profile','2026-08-29 11:05:42'),(24,'demo-member-17','demo.member17@example.com','register','128.199.30.7','Singapore',NULL,NULL,'Singapore','seed/demo-profile','2026-09-02 11:05:42'),(25,'demo-member-18','demo.member18@example.com','register','177.54.10.33','Brazil',NULL,NULL,'Sao Paulo','seed/demo-profile','2026-09-06 11:05:42'),(26,'demo-member-19','demo.member19@example.com','register','175.106.20.44','South Korea',NULL,NULL,'Seoul','seed/demo-profile','2026-09-10 11:05:42'),(27,'demo-member-20','demo.member20@example.com','register','88.16.30.21','Spain',NULL,NULL,'Madrid','seed/demo-profile','2026-09-14 11:05:42'),(28,'MtTk43nCRWicn9XwqYobCc2DIU2uqbI6','admin@uilines.dev','login','::1',NULL,NULL,NULL,NULL,'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','2026-09-18 11:06:12'),(29,'MtTk43nCRWicn9XwqYobCc2DIU2uqbI6','admin@uilines.dev','login','::1',NULL,NULL,NULL,NULL,'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','2026-09-18 11:06:21'),(30,'MtTk43nCRWicn9XwqYobCc2DIU2uqbI6','admin@uilines.dev','login','::1',NULL,NULL,NULL,NULL,'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','2026-09-18 11:07:51'),(31,'MtTk43nCRWicn9XwqYobCc2DIU2uqbI6','admin@uilines.dev','login','::1',NULL,NULL,NULL,NULL,'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','2026-09-18 11:08:01'),(32,'MtTk43nCRWicn9XwqYobCc2DIU2uqbI6','admin@uilines.dev','login','::1',NULL,NULL,NULL,NULL,'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','2026-09-18 11:09:52'),(33,'MtTk43nCRWicn9XwqYobCc2DIU2uqbI6','admin@uilines.dev','login','::1',NULL,NULL,NULL,NULL,'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','2026-09-18 11:11:13'),(34,'MtTk43nCRWicn9XwqYobCc2DIU2uqbI6','admin@uilines.dev','login','::1',NULL,NULL,NULL,NULL,'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','2026-09-18 11:14:51'),(35,'MtTk43nCRWicn9XwqYobCc2DIU2uqbI6','admin@uilines.dev','login','::1',NULL,NULL,NULL,NULL,'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','2026-09-18 11:21:04'),(36,'MtTk43nCRWicn9XwqYobCc2DIU2uqbI6','admin@uilines.dev','login','::1',NULL,NULL,NULL,NULL,'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','2026-09-18 11:21:53'),(37,'MtTk43nCRWicn9XwqYobCc2DIU2uqbI6','admin@uilines.dev','login','::1',NULL,NULL,NULL,NULL,'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','2026-09-18 11:24:46'),(38,'MtTk43nCRWicn9XwqYobCc2DIU2uqbI6','admin@uilines.dev','login','::1',NULL,NULL,NULL,NULL,'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','2026-09-18 11:26:11'),(39,'MtTk43nCRWicn9XwqYobCc2DIU2uqbI6','admin@uilines.dev','login','::1',NULL,NULL,NULL,NULL,'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','2026-09-18 11:39:32'),(40,'MtTk43nCRWicn9XwqYobCc2DIU2uqbI6','admin@uilines.dev','login','::1',NULL,NULL,NULL,NULL,'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','2026-09-18 11:40:00'),(41,'MtTk43nCRWicn9XwqYobCc2DIU2uqbI6','admin@uilines.dev','login','::1',NULL,NULL,NULL,NULL,'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','2026-09-18 11:40:21'),(42,'MtTk43nCRWicn9XwqYobCc2DIU2uqbI6','admin@uilines.dev','login','::1',NULL,NULL,NULL,NULL,'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','2026-09-18 11:40:46'),(43,'MtTk43nCRWicn9XwqYobCc2DIU2uqbI6','admin@uilines.dev','login','::1',NULL,NULL,NULL,NULL,'curl/8.7.1','2026-09-18 11:41:00'),(44,'MtTk43nCRWicn9XwqYobCc2DIU2uqbI6','admin@uilines.dev','login','::1',NULL,NULL,NULL,NULL,'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','2026-09-18 11:41:18'),(45,'MtTk43nCRWicn9XwqYobCc2DIU2uqbI6','admin@uilines.dev','login','::1',NULL,NULL,NULL,NULL,'curl/8.7.1','2026-09-18 11:44:40'),(46,'MtTk43nCRWicn9XwqYobCc2DIU2uqbI6','admin@uilines.dev','login','::1',NULL,NULL,NULL,NULL,'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','2026-09-18 11:45:05'),(47,'MtTk43nCRWicn9XwqYobCc2DIU2uqbI6','admin@uilines.dev','login','::1',NULL,NULL,NULL,NULL,'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','2026-09-18 11:45:34'),(48,'MtTk43nCRWicn9XwqYobCc2DIU2uqbI6','admin@uilines.dev','login','::1',NULL,NULL,NULL,NULL,'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','2026-09-18 11:45:57'),(49,'MtTk43nCRWicn9XwqYobCc2DIU2uqbI6','admin@uilines.dev','login','::1',NULL,NULL,NULL,NULL,'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','2026-09-18 11:46:12'),(50,'MtTk43nCRWicn9XwqYobCc2DIU2uqbI6','admin@uilines.dev','login','::1',NULL,NULL,NULL,NULL,'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','2026-09-18 11:46:38'),(51,'MtTk43nCRWicn9XwqYobCc2DIU2uqbI6','admin@uilines.dev','login','::1',NULL,NULL,NULL,NULL,'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','2026-09-18 11:47:11'),(52,'MtTk43nCRWicn9XwqYobCc2DIU2uqbI6','admin@uilines.dev','login','::1',NULL,NULL,NULL,NULL,'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','2026-09-18 11:48:05'),(53,'MtTk43nCRWicn9XwqYobCc2DIU2uqbI6','admin@uilines.dev','login','::1',NULL,NULL,NULL,NULL,'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','2026-09-18 11:48:21'),(54,'MtTk43nCRWicn9XwqYobCc2DIU2uqbI6','admin@uilines.dev','login','::1',NULL,NULL,NULL,NULL,'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','2026-09-18 11:48:41'),(55,'MtTk43nCRWicn9XwqYobCc2DIU2uqbI6','admin@uilines.dev','login','::1',NULL,NULL,NULL,NULL,'curl/8.7.1','2026-09-18 11:50:43'),(56,'MtTk43nCRWicn9XwqYobCc2DIU2uqbI6','admin@uilines.dev','login','::1',NULL,NULL,NULL,NULL,'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','2026-09-18 11:51:07'),(57,'MtTk43nCRWicn9XwqYobCc2DIU2uqbI6','admin@uilines.dev','login','::1',NULL,NULL,NULL,NULL,'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','2026-09-18 11:51:35'),(58,'MtTk43nCRWicn9XwqYobCc2DIU2uqbI6','admin@uilines.dev','login','::1',NULL,NULL,NULL,NULL,'curl/8.7.1','2026-09-18 11:55:46'),(59,'MtTk43nCRWicn9XwqYobCc2DIU2uqbI6','admin@uilines.dev','login','::1',NULL,NULL,NULL,NULL,'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','2026-09-18 11:56:18'),(60,'MtTk43nCRWicn9XwqYobCc2DIU2uqbI6','admin@uilines.dev','login','::1',NULL,NULL,NULL,NULL,'curl/8.7.1','2026-09-18 12:05:16'),(61,'MtTk43nCRWicn9XwqYobCc2DIU2uqbI6','admin@uilines.dev','login','::1',NULL,NULL,NULL,NULL,'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','2026-09-18 12:06:09'),(62,'MtTk43nCRWicn9XwqYobCc2DIU2uqbI6','admin@uilines.dev','login','::1',NULL,NULL,NULL,NULL,'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','2026-09-18 12:06:37'),(63,'MtTk43nCRWicn9XwqYobCc2DIU2uqbI6','admin@uilines.dev','login','::1',NULL,NULL,NULL,NULL,'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','2026-09-18 12:07:04'),(64,'MtTk43nCRWicn9XwqYobCc2DIU2uqbI6','admin@uilines.dev','login','::1',NULL,NULL,NULL,NULL,'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','2026-09-18 12:07:38'),(65,'MtTk43nCRWicn9XwqYobCc2DIU2uqbI6','admin@uilines.dev','login','::1',NULL,NULL,NULL,NULL,'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','2026-09-18 12:08:10'),(66,'MtTk43nCRWicn9XwqYobCc2DIU2uqbI6','admin@uilines.dev','login','::1',NULL,NULL,NULL,NULL,'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','2026-09-18 12:10:18'),(67,'MtTk43nCRWicn9XwqYobCc2DIU2uqbI6','admin@uilines.dev','login','::1',NULL,NULL,NULL,NULL,'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','2026-09-18 12:11:01'),(68,'MtTk43nCRWicn9XwqYobCc2DIU2uqbI6','admin@uilines.dev','login','::1',NULL,NULL,NULL,NULL,'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','2026-09-18 12:11:44'),(69,'MtTk43nCRWicn9XwqYobCc2DIU2uqbI6','admin@uilines.dev','login','::1',NULL,NULL,NULL,NULL,'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','2026-09-18 12:12:23'),(70,'MtTk43nCRWicn9XwqYobCc2DIU2uqbI6','admin@uilines.dev','login','::1',NULL,NULL,NULL,NULL,'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','2026-09-18 12:13:29'),(71,'MtTk43nCRWicn9XwqYobCc2DIU2uqbI6','admin@uilines.dev','login','::1',NULL,NULL,NULL,NULL,'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','2026-09-18 12:14:08'),(72,'UJZd1gQ2pUHHMAkoHHapNY9QW54yEile','test@abc.com','register','::1',NULL,NULL,NULL,NULL,'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36','2026-09-18 12:16:19'),(73,'UJZd1gQ2pUHHMAkoHHapNY9QW54yEile','test@abc.com','login','::1',NULL,NULL,NULL,NULL,'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36','2026-09-18 12:16:19'),(74,'MtTk43nCRWicn9XwqYobCc2DIU2uqbI6','admin@uilines.dev','login','::1',NULL,NULL,NULL,NULL,'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','2026-09-18 12:17:11'),(75,'MtTk43nCRWicn9XwqYobCc2DIU2uqbI6','admin@uilines.dev','login','::1',NULL,NULL,NULL,NULL,'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','2026-09-18 12:22:31'),(76,'MtTk43nCRWicn9XwqYobCc2DIU2uqbI6','admin@uilines.dev','login','::1',NULL,NULL,NULL,NULL,'curl/8.7.1','2026-09-18 12:26:32'),(77,'MtTk43nCRWicn9XwqYobCc2DIU2uqbI6','admin@uilines.dev','login','::1',NULL,NULL,NULL,NULL,'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','2026-09-18 12:27:06'),(78,'MtTk43nCRWicn9XwqYobCc2DIU2uqbI6','admin@uilines.dev','login','::1',NULL,NULL,NULL,NULL,'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','2026-09-18 12:31:33'),(79,'MtTk43nCRWicn9XwqYobCc2DIU2uqbI6','admin@uilines.dev','login','::1',NULL,NULL,NULL,NULL,'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','2026-09-18 12:31:39'),(80,'MtTk43nCRWicn9XwqYobCc2DIU2uqbI6','admin@uilines.dev','login','::1',NULL,NULL,NULL,NULL,'curl/8.7.1','2026-09-18 12:37:06'),(81,'MtTk43nCRWicn9XwqYobCc2DIU2uqbI6','admin@uilines.dev','login','::1',NULL,NULL,NULL,NULL,'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','2026-09-18 12:37:34'),(82,'MtTk43nCRWicn9XwqYobCc2DIU2uqbI6','admin@uilines.dev','login','::1',NULL,NULL,NULL,NULL,'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','2026-09-18 12:39:24'),(83,'MtTk43nCRWicn9XwqYobCc2DIU2uqbI6','admin@uilines.dev','login','::1',NULL,NULL,NULL,NULL,'curl/8.7.1','2026-09-18 12:43:26'),(86,'MtTk43nCRWicn9XwqYobCc2DIU2uqbI6','admin@uilines.dev','login','::1',NULL,NULL,NULL,NULL,'curl/8.7.1','2026-09-18 12:44:22'),(89,'MtTk43nCRWicn9XwqYobCc2DIU2uqbI6','admin@uilines.dev','login','::1',NULL,NULL,NULL,NULL,'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36','2026-09-18 12:45:48'),(90,'MtTk43nCRWicn9XwqYobCc2DIU2uqbI6','admin@uilines.dev','login','::1',NULL,NULL,NULL,NULL,'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','2026-09-18 12:55:37'),(91,'rXi36d6MyI8p0fn8rRhZwMiR5GGA7SVT','test@uilines.dev','login','::1',NULL,NULL,NULL,NULL,'Bun/1.4.0','2026-09-18 12:56:11'),(92,'rXi36d6MyI8p0fn8rRhZwMiR5GGA7SVT','test@uilines.dev','login','::1',NULL,NULL,NULL,NULL,'Bun/1.4.0','2026-09-18 12:56:11'),(93,'rXi36d6MyI8p0fn8rRhZwMiR5GGA7SVT','test@uilines.dev','login','::1',NULL,NULL,NULL,NULL,'Bun/1.4.0','2026-09-18 12:56:11'),(94,'rXi36d6MyI8p0fn8rRhZwMiR5GGA7SVT','test@uilines.dev','login','::1',NULL,NULL,NULL,NULL,'Bun/1.4.0','2026-09-18 12:56:12'),(95,'rXi36d6MyI8p0fn8rRhZwMiR5GGA7SVT','test@uilines.dev','login','::1',NULL,NULL,NULL,NULL,'Bun/1.4.0','2026-09-18 12:56:22'),(96,'rXi36d6MyI8p0fn8rRhZwMiR5GGA7SVT','test@uilines.dev','login','::1',NULL,NULL,NULL,NULL,'Bun/1.4.0','2026-09-18 12:56:23'),(97,'rXi36d6MyI8p0fn8rRhZwMiR5GGA7SVT','test@uilines.dev','login','::1',NULL,NULL,NULL,NULL,'curl/8.7.1','2026-09-18 12:56:37'),(98,'rXi36d6MyI8p0fn8rRhZwMiR5GGA7SVT','test@uilines.dev','login','::1',NULL,NULL,NULL,NULL,'curl/8.7.1','2026-09-18 12:57:07'),(99,'rXi36d6MyI8p0fn8rRhZwMiR5GGA7SVT','test@uilines.dev','login','::1',NULL,NULL,NULL,NULL,'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','2026-09-18 13:15:20'),(100,'rXi36d6MyI8p0fn8rRhZwMiR5GGA7SVT','test@uilines.dev','login','::1',NULL,NULL,NULL,NULL,'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','2026-09-18 13:23:09'),(101,'rXi36d6MyI8p0fn8rRhZwMiR5GGA7SVT','test@uilines.dev','login','::1',NULL,NULL,NULL,NULL,'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','2026-09-18 13:26:21'),(102,'rXi36d6MyI8p0fn8rRhZwMiR5GGA7SVT','test@uilines.dev','login','::1',NULL,NULL,NULL,NULL,'curl/8.7.1','2026-09-18 13:34:20'),(103,'rXi36d6MyI8p0fn8rRhZwMiR5GGA7SVT','test@uilines.dev','login','::1',NULL,NULL,NULL,NULL,'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','2026-09-18 13:34:49'),(104,'UJZd1gQ2pUHHMAkoHHapNY9QW54yEile','test@abc.com','login','::1',NULL,NULL,NULL,NULL,'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36','2026-09-18 13:36:40'),(105,'rXi36d6MyI8p0fn8rRhZwMiR5GGA7SVT','test@uilines.dev','login','::1',NULL,NULL,NULL,NULL,'curl/8.7.1','2026-09-18 13:43:56'),(106,'rXi36d6MyI8p0fn8rRhZwMiR5GGA7SVT','test@uilines.dev','login','::1',NULL,NULL,NULL,NULL,'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','2026-09-18 13:44:34'),(107,'rXi36d6MyI8p0fn8rRhZwMiR5GGA7SVT','test@uilines.dev','login','::1',NULL,NULL,NULL,NULL,'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','2026-09-18 13:45:10'),(108,'rXi36d6MyI8p0fn8rRhZwMiR5GGA7SVT','test@uilines.dev','login','::1',NULL,NULL,NULL,NULL,'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','2026-09-18 13:45:46'),(109,'rXi36d6MyI8p0fn8rRhZwMiR5GGA7SVT','test@uilines.dev','login','::1',NULL,NULL,NULL,NULL,'curl/8.7.1','2026-09-18 13:52:19'),(110,'rXi36d6MyI8p0fn8rRhZwMiR5GGA7SVT','test@uilines.dev','login','::1',NULL,NULL,NULL,NULL,'curl/8.7.1','2026-09-18 13:52:21'),(111,'UJZd1gQ2pUHHMAkoHHapNY9QW54yEile','test@abc.com','login','::1',NULL,NULL,NULL,NULL,'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36','2026-09-18 13:53:52'),(112,'rXi36d6MyI8p0fn8rRhZwMiR5GGA7SVT','test@uilines.dev','login','::1',NULL,NULL,NULL,NULL,'curl/8.7.1','2026-09-18 13:56:51'),(113,'rXi36d6MyI8p0fn8rRhZwMiR5GGA7SVT','test@uilines.dev','login','::1',NULL,NULL,NULL,NULL,'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','2026-09-18 13:57:38'),(114,'rXi36d6MyI8p0fn8rRhZwMiR5GGA7SVT','test@uilines.dev','login','::1',NULL,NULL,NULL,NULL,'curl/8.7.1','2026-09-18 13:58:43'),(115,'rXi36d6MyI8p0fn8rRhZwMiR5GGA7SVT','test@uilines.dev','login','::1',NULL,NULL,NULL,NULL,'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','2026-09-18 14:02:37'),(116,'rXi36d6MyI8p0fn8rRhZwMiR5GGA7SVT','test@uilines.dev','login','::1',NULL,NULL,NULL,NULL,'curl/8.7.1','2026-09-18 14:03:17'),(117,'rXi36d6MyI8p0fn8rRhZwMiR5GGA7SVT','test@uilines.dev','login','::1',NULL,NULL,NULL,NULL,'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','2026-09-18 14:03:36'),(118,'rXi36d6MyI8p0fn8rRhZwMiR5GGA7SVT','test@uilines.dev','login','::1',NULL,NULL,NULL,NULL,'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','2026-09-18 14:03:57'),(119,'rXi36d6MyI8p0fn8rRhZwMiR5GGA7SVT','test@uilines.dev','login','::1',NULL,NULL,NULL,NULL,'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','2026-09-18 14:21:20'),(120,'UJZd1gQ2pUHHMAkoHHapNY9QW54yEile','test@abc.com','login','::1',NULL,NULL,NULL,NULL,'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36','2026-09-18 14:21:26'),(121,'rXi36d6MyI8p0fn8rRhZwMiR5GGA7SVT','test@uilines.dev','login','::1',NULL,NULL,NULL,NULL,'curl/8.7.1','2026-09-18 14:24:16'),(122,'rXi36d6MyI8p0fn8rRhZwMiR5GGA7SVT','test@uilines.dev','login','::1',NULL,NULL,NULL,NULL,'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','2026-09-18 14:24:43'),(123,'rXi36d6MyI8p0fn8rRhZwMiR5GGA7SVT','test@uilines.dev','login','::1',NULL,NULL,NULL,NULL,'curl/8.7.1','2026-09-18 15:09:36'),(124,'rXi36d6MyI8p0fn8rRhZwMiR5GGA7SVT','test@uilines.dev','login','::1',NULL,NULL,NULL,NULL,'curl/8.7.1','2026-09-18 15:12:55'),(125,NULL,'qa.view@uilines.dev','login','::1',NULL,NULL,NULL,NULL,'curl/8.7.1','2026-09-18 15:12:56'),(126,'rXi36d6MyI8p0fn8rRhZwMiR5GGA7SVT','test@uilines.dev','login','::1',NULL,NULL,NULL,NULL,'curl/8.7.1','2026-09-18 15:35:45'),(127,NULL,'qa.ro@uilines.dev','login','::1',NULL,NULL,NULL,NULL,'curl/8.7.1','2026-09-18 15:35:45'),(128,'79UhVSTRB4Oh5ibyIoJfR2JqvkI5NXdb','test@test.com','login','::1',NULL,NULL,NULL,NULL,'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36','2026-09-18 15:42:54'),(129,'rXi36d6MyI8p0fn8rRhZwMiR5GGA7SVT','test@uilines.dev','login','43.198.248.55',NULL,NULL,NULL,NULL,'curl/8.7.1','2026-09-18 17:50:18'),(130,'MtTk43nCRWicn9XwqYobCc2DIU2uqbI6','admin@uilines.dev','login','43.198.248.55',NULL,NULL,NULL,NULL,'curl/8.7.1','2026-09-18 17:52:18'),(131,'MtTk43nCRWicn9XwqYobCc2DIU2uqbI6','admin@uilines.dev','login','43.198.248.55',NULL,NULL,NULL,NULL,'curl/8.7.1','2026-09-18 17:52:19'),(132,'MtTk43nCRWicn9XwqYobCc2DIU2uqbI6','admin@uilines.dev','login','43.198.248.55',NULL,NULL,NULL,NULL,'curl/8.7.1','2026-09-18 17:52:32'),(133,'MtTk43nCRWicn9XwqYobCc2DIU2uqbI6','admin@uilines.dev','login','43.198.248.55',NULL,NULL,NULL,NULL,'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36','2026-09-18 17:52:48'),(134,'MtTk43nCRWicn9XwqYobCc2DIU2uqbI6','admin@uilines.dev','login','43.198.248.55',NULL,NULL,NULL,NULL,'curl/8.7.1','2026-09-18 17:56:21'),(135,'MtTk43nCRWicn9XwqYobCc2DIU2uqbI6','admin@uilines.dev','login','43.198.248.55',NULL,NULL,NULL,NULL,'curl/8.7.1','2026-09-18 18:02:56'),(136,'79UhVSTRB4Oh5ibyIoJfR2JqvkI5NXdb','test@test.com','login','183.223.133.201',NULL,NULL,NULL,NULL,'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36','2026-09-18 18:50:26'),(137,'UJZd1gQ2pUHHMAkoHHapNY9QW54yEile','test@abc.com','login','183.223.133.201',NULL,NULL,NULL,NULL,'Mozilla/5.0 (iPhone; CPU iPhone OS 26_4_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/153.0.8010.24 Mobile/15E148 Safari/604.1','2026-09-18 20:27:38'),(138,'1wKpQRdHAxKWEvupzUVg1CPWEku04eAk','a@test.com','register','183.223.133.201',NULL,NULL,NULL,NULL,'Mozilla/5.0 (iPhone; CPU iPhone OS 26_4_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/153.0.8010.24 Mobile/15E148 Safari/604.1','2026-09-18 20:31:35'),(139,'1wKpQRdHAxKWEvupzUVg1CPWEku04eAk','a@test.com','login','183.223.133.201',NULL,NULL,NULL,NULL,'Mozilla/5.0 (iPhone; CPU iPhone OS 26_4_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/153.0.8010.24 Mobile/15E148 Safari/604.1','2026-09-18 20:31:36'),(140,'MtTk43nCRWicn9XwqYobCc2DIU2uqbI6','admin@uilines.dev','login','183.223.133.201',NULL,NULL,NULL,NULL,'curl/8.7.1','2026-09-18 21:09:26'),(141,'UJZd1gQ2pUHHMAkoHHapNY9QW54yEile','test@abc.com','login','183.223.133.201',NULL,NULL,NULL,NULL,'Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1','2026-09-18 21:37:48'),(142,'MtTk43nCRWicn9XwqYobCc2DIU2uqbI6','admin@uilines.dev','login','183.223.133.201',NULL,NULL,NULL,NULL,'curl/8.7.1','2026-09-18 21:38:06'),(143,'MtTk43nCRWicn9XwqYobCc2DIU2uqbI6','admin@uilines.dev','login','110.187.90.86',NULL,NULL,NULL,NULL,'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/132.0.0.0 Safari/537.36','2026-09-19 07:10:57');
/*!40000 ALTER TABLE `memberLogs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `newsletterSubscribers`
--

DROP TABLE IF EXISTS `newsletterSubscribers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `newsletterSubscribers` (
  `id` int NOT NULL AUTO_INCREMENT,
  `email` varchar(255) NOT NULL,
  `status` enum('subscribed','unsubscribed') NOT NULL DEFAULT 'subscribed',
  `source` varchar(64) NOT NULL DEFAULT 'footer',
  `locale` varchar(8) DEFAULT NULL,
  `userId` varchar(36) DEFAULT NULL,
  `subscribedAt` timestamp NOT NULL DEFAULT (now()),
  `unsubscribedAt` timestamp NULL DEFAULT NULL,
  `createdAt` timestamp NOT NULL DEFAULT (now()),
  `updatedAt` timestamp NOT NULL DEFAULT (now()) ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `newsletterSubscribers_email_unique` (`email`),
  KEY `newsletterSubscribers_userId_user_id_fk` (`userId`),
  KEY `idx_newsletter_status_created` (`status`,`createdAt`),
  CONSTRAINT `newsletterSubscribers_userId_user_id_fk` FOREIGN KEY (`userId`) REFERENCES `user` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `newsletterSubscribers`
--

LOCK TABLES `newsletterSubscribers` WRITE;
/*!40000 ALTER TABLE `newsletterSubscribers` DISABLE KEYS */;
INSERT INTO `newsletterSubscribers` VALUES (3,'alice@example.com','subscribed','footer','en',NULL,'2026-09-17 17:15:31',NULL,'2026-09-17 17:14:05','2026-09-17 17:15:31'),(4,'liuwei@example.cn','subscribed','footer','zh',NULL,'2026-09-15 17:14:05',NULL,'2026-09-17 17:14:05','2026-09-17 17:14:05'),(5,'unsub@example.com','unsubscribed','footer','en',NULL,'2026-09-07 17:14:05','2026-09-14 17:14:05','2026-09-17 17:14:05','2026-09-17 17:14:05'),(8,'kisswen660@gmail.com','subscribed','footer','en','rXi36d6MyI8p0fn8rRhZwMiR5GGA7SVT','2026-09-17 17:32:20',NULL,'2026-09-17 17:32:20','2026-09-17 17:32:20');
/*!40000 ALTER TABLE `newsletterSubscribers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notifications`
--

DROP TABLE IF EXISTS `notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notifications` (
  `id` int NOT NULL AUTO_INCREMENT,
  `kind` varchar(32) NOT NULL DEFAULT 'system',
  `title` varchar(150) NOT NULL,
  `body` varchar(300) DEFAULT NULL,
  `linkUrl` varchar(255) DEFAULT NULL,
  `dedupeKey` varchar(64) DEFAULT NULL,
  `isRead` tinyint(1) NOT NULL DEFAULT '0',
  `readAt` timestamp NULL DEFAULT NULL,
  `createdAt` timestamp NOT NULL DEFAULT (now()),
  `updatedAt` timestamp NOT NULL DEFAULT (now()) ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `notifications_dedupeKey_unique` (`dedupeKey`),
  KEY `idx_notifications_read_created` (`isRead`,`createdAt`),
  KEY `idx_notifications_created` (`createdAt`)
) ENGINE=InnoDB AUTO_INCREMENT=56 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notifications`
--

LOCK TABLES `notifications` WRITE;
/*!40000 ALTER TABLE `notifications` DISABLE KEYS */;
INSERT INTO `notifications` VALUES (1,'order','有订单待付款','当前有 3 笔订单等待付款，可在订单管理中确认收款或取消。','/admin/orders','demo:pending-orders',0,NULL,'2026-09-18 15:35:23','2026-09-18 15:37:23'),(2,'message','新留言待回访','有 1 条来自前台「联系我们」的留言还没有回访。','/admin/messages','demo:pending-messages',1,'2026-09-18 15:42:07','2026-09-18 15:02:23','2026-09-18 15:42:07'),(3,'stock','低库存预警','1 个在售商品库存低于 10 件，建议尽快补货。','/admin/products','demo:low-stock',0,NULL,'2026-09-18 12:37:23','2026-09-18 15:37:23'),(4,'member','近 7 天新增会员','最近 7 天新增 2 位会员，可在会员管理中查看来源国家。','/admin/customers','demo:new-members',0,NULL,'2026-09-18 06:37:23','2026-09-18 15:37:23'),(5,'coupon','优惠码核销统计','累计核销 1 次，抵扣 $6.00。','/admin/coupons','demo:coupon-usage',0,NULL,'2026-09-17 15:37:23','2026-09-18 15:37:23');
/*!40000 ALTER TABLE `notifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `orderItems`
--

DROP TABLE IF EXISTS `orderItems`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `orderItems` (
  `id` int NOT NULL AUTO_INCREMENT,
  `orderId` int NOT NULL,
  `productId` int DEFAULT NULL,
  `slug` varchar(220) NOT NULL,
  `name` varchar(200) NOT NULL,
  `image` varchar(255) DEFAULT NULL,
  `unitPriceCents` int NOT NULL,
  `qty` int NOT NULL,
  `totalCents` int NOT NULL,
  `attributes` json DEFAULT NULL,
  `nameEn` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_orderItems_orderId` (`orderId`),
  KEY `idx_orderItems_productId` (`productId`),
  CONSTRAINT `orderItems_orderId_orders_id_fk` FOREIGN KEY (`orderId`) REFERENCES `orders` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=59 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orderItems`
--

LOCK TABLES `orderItems` WRITE;
/*!40000 ALTER TABLE `orderItems` DISABLE KEYS */;
INSERT INTO `orderItems` VALUES (4,4,25,'cyber-x-pod-system-kit','Cyber X 烟弹系统套装','/images/products/cyber-x-pod.jpg',5000,8,40000,NULL,'Cyber X Pod System Kit'),(5,4,30,'strawberry-100ml-vape-juice','草莓 100ml 烟油','/images/products/strawberry-juice.jpg',3000,5,15000,NULL,'Strawberry 100ml Vape Juice'),(6,10,25,'cyber-x-pod-system-kit','Cyber X 烟弹系统套装','/images/products/cyber-x-pod.jpg',5000,1,5000,NULL,'Cyber X Pod System Kit'),(7,11,28,'level-x-boost-device-kit','Level X Boost 设备套装','/images/products/level-x-boost.jpg',6700,1,6700,NULL,'Level X Boost Device Kit'),(8,12,31,'blue-bar-disposable-vape-kit','Blue Bar 一次性电子烟套装','/images/products/blue-bar.jpg',3000,2,6000,NULL,'Blue Bar Disposable Vape Kit'),(9,13,30,'strawberry-100ml-vape-juice','草莓 100ml 烟油','/images/products/strawberry-juice.jpg',3000,3,9000,NULL,'Strawberry 100ml Vape Juice'),(10,14,27,'geek-bar-lite-disposable-pod','Geek Bar Lite 一次性烟弹','/images/products/geek-bar-lite.jpg',2000,1,2000,NULL,'Geek Bar Lite Disposable Pod'),(11,15,29,'argus-gt-2-starter-kit-200w','Argus GT 2 入门套装 200w','/images/products/argus-gt2.jpg',7000,1,7000,NULL,'Argus GT 2 Starter Kit 200w'),(12,16,25,'cyber-x-pod-system-kit','Cyber X 烟弹系统套装','/images/products/cyber-x-pod.jpg',5000,2,10000,NULL,'Cyber X Pod System Kit'),(13,17,26,'refillable-pods-2ml','可注油烟弹 2ml - 2 颗装','/images/products/refillable-pods.jpg',2500,1,2500,NULL,'Refillable Pods 2ml - 2 x Pods'),(14,18,32,'prefilled-disposable-pod-kit','预注油烟弹套装','/images/products/prefilled-pod.jpg',1000,1,1000,NULL,'Prefilled Disposable Pod Kit'),(15,19,31,'blue-bar-disposable-vape-kit','Blue Bar 一次性电子烟套装','/images/products/blue-bar.jpg',3000,1,3000,NULL,'Blue Bar Disposable Vape Kit'),(16,20,28,'level-x-boost-device-kit','Level X Boost 设备套装','/images/products/level-x-boost.jpg',6700,1,6700,NULL,'Level X Boost Device Kit'),(17,21,30,'strawberry-100ml-vape-juice','草莓 100ml 烟油','/images/products/strawberry-juice.jpg',3000,2,6000,NULL,'Strawberry 100ml Vape Juice'),(18,22,25,'cyber-x-pod-system-kit','Cyber X 烟弹系统套装','/images/products/cyber-x-pod.jpg',5000,1,5000,NULL,'Cyber X Pod System Kit'),(19,23,29,'argus-gt-2-starter-kit-200w','Argus GT 2 入门套装 200w','/images/products/argus-gt2.jpg',7000,1,7000,NULL,'Argus GT 2 Starter Kit 200w'),(29,33,26,'refillable-pods-2ml','可注油烟弹 2ml - 2 颗装','/images/products/refillable-pods.jpg',2500,3,7500,NULL,'Refillable Pods 2ml - 2 x Pods'),(30,33,27,'geek-bar-lite-disposable-pod','Geek Bar Lite 一次性烟弹','/images/products/geek-bar-lite.jpg',2000,1,2000,NULL,'Geek Bar Lite Disposable Pod'),(31,33,28,'level-x-boost-device-kit','Level X Boost 设备套装','/images/products/level-x-boost.jpg',6700,1,6700,NULL,'Level X Boost Device Kit'),(32,33,30,'strawberry-100ml-vape-juice','草莓 100ml 烟油','/images/products/strawberry-juice.jpg',3000,1,3000,NULL,'Strawberry 100ml Vape Juice'),(33,33,31,'blue-bar-disposable-vape-kit','Blue Bar 一次性电子烟套装','/images/products/blue-bar.jpg',3000,1,3000,NULL,'Blue Bar Disposable Vape Kit'),(55,51,25,'cyber-x-pod-system-kit','Cyber X 烟弹系统套装','/images/products/cyber-x-pod.jpg',5000,2,10000,NULL,'Cyber X Pod System Kit'),(56,51,26,'refillable-pods-2ml','可注油烟弹 2ml - 2 颗装','/images/products/refillable-pods.jpg',2500,1,2500,NULL,'Refillable Pods 2ml - 2 x Pods'),(57,52,31,'blue-bar-disposable-vape-kit','Blue Bar 一次性电子烟套装','/images/products/blue-bar.jpg',3000,1,3000,NULL,'Blue Bar Disposable Vape Kit'),(58,53,25,'cyber-x-pod-system-kit','Cyber X 烟弹系统套装','/images/products/cyber-x-pod.jpg',5000,1,5000,NULL,'Cyber X Pod System Kit');
/*!40000 ALTER TABLE `orderItems` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `orderShipments`
--

DROP TABLE IF EXISTS `orderShipments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `orderShipments` (
  `id` int NOT NULL AUTO_INCREMENT,
  `orderId` int NOT NULL,
  `carrier` varchar(100) NOT NULL,
  `trackingNo` varchar(64) NOT NULL,
  `trackingUrl` varchar(500) DEFAULT NULL,
  `status` enum('in_transit','delivered','exception') NOT NULL DEFAULT 'in_transit',
  `note` text,
  `shippedAt` timestamp NULL DEFAULT NULL,
  `deliveredAt` timestamp NULL DEFAULT NULL,
  `createdAt` timestamp NOT NULL DEFAULT (now()),
  `updatedAt` timestamp NOT NULL DEFAULT (now()) ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_orderShipments_order` (`orderId`),
  KEY `idx_orderShipments_trackingNo` (`trackingNo`),
  CONSTRAINT `orderShipments_orderId_orders_id_fk` FOREIGN KEY (`orderId`) REFERENCES `orders` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orderShipments`
--

LOCK TABLES `orderShipments` WRITE;
/*!40000 ALTER TABLE `orderShipments` DISABLE KEYS */;
INSERT INTO `orderShipments` VALUES (2,33,'sf','sf14232432',NULL,'delivered','sfdsafdsafdsfdas','2026-09-18 13:54:35','2026-09-18 13:54:35','2026-09-18 13:54:34','2026-09-18 13:54:34');
/*!40000 ALTER TABLE `orderShipments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `orders`
--

DROP TABLE IF EXISTS `orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `orders` (
  `id` int NOT NULL AUTO_INCREMENT,
  `orderNumber` varchar(32) NOT NULL,
  `userId` varchar(36) DEFAULT NULL,
  `email` varchar(255) NOT NULL,
  `status` enum('pending','paid','shipped','completed','cancelled','refunded') NOT NULL DEFAULT 'pending',
  `currency` varchar(3) NOT NULL DEFAULT 'USD',
  `subtotalCents` int NOT NULL,
  `discountCents` int NOT NULL DEFAULT '0',
  `shippingCents` int NOT NULL DEFAULT '0',
  `totalCents` int NOT NULL,
  `couponId` int DEFAULT NULL,
  `couponCode` varchar(32) DEFAULT NULL,
  `note` text,
  `recipientName` varchar(100) NOT NULL,
  `phone` varchar(32) NOT NULL,
  `country` varchar(100) NOT NULL,
  `province` varchar(100) DEFAULT NULL,
  `city` varchar(100) DEFAULT NULL,
  `district` varchar(100) DEFAULT NULL,
  `addressLine1` varchar(255) NOT NULL,
  `addressLine2` varchar(255) DEFAULT NULL,
  `postalCode` varchar(32) DEFAULT NULL,
  `paidAt` timestamp NULL DEFAULT NULL,
  `createdAt` timestamp NOT NULL DEFAULT (now()),
  `updatedAt` timestamp NOT NULL DEFAULT (now()) ON UPDATE CURRENT_TIMESTAMP,
  `trackingNo` varchar(64) DEFAULT NULL,
  `shippedAt` timestamp NULL DEFAULT NULL,
  `completedAt` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `orders_orderNumber_unique` (`orderNumber`),
  KEY `idx_orders_user_createdAt` (`userId`,`createdAt`),
  KEY `idx_orders_status` (`status`),
  KEY `idx_orders_couponId` (`couponId`),
  CONSTRAINT `orders_couponId_coupons_id_fk` FOREIGN KEY (`couponId`) REFERENCES `coupons` (`id`) ON DELETE SET NULL,
  CONSTRAINT `orders_userId_user_id_fk` FOREIGN KEY (`userId`) REFERENCES `user` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=54 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orders`
--

LOCK TABLES `orders` WRITE;
/*!40000 ALTER TABLE `orders` DISABLE KEYS */;
INSERT INTO `orders` VALUES (4,'UL20260917216273','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6','admin@uilines.dev','pending','USD',55000,0,0,55000,NULL,NULL,NULL,'kjllfda','87326189637218','dsafdsa','fdsa','ds',NULL,'fakjkfldsajfdkla',NULL,'fda',NULL,'2026-09-17 14:39:32','2026-09-17 14:39:32',NULL,NULL,NULL),(10,'DEMO-0001','demo-member-01','demo.member01@example.com','completed','USD',5000,0,0,5000,NULL,NULL,NULL,'James Carter','+1 555 0100','United States',NULL,'New York',NULL,'1 Demo Street',NULL,NULL,'2026-08-21 11:14:05','2026-08-21 11:14:05','2026-09-18 13:36:01',NULL,'2026-08-21 11:14:05','2026-08-23 11:14:05'),(11,'DEMO-0002','demo-member-02','demo.member02@example.com','completed','USD',6700,0,0,6700,NULL,NULL,NULL,'Sophia Bennett','+1 555 0100','United States',NULL,'Los Angeles',NULL,'2 Demo Street',NULL,NULL,'2026-08-24 11:14:05','2026-08-24 11:14:05','2026-09-18 13:36:01',NULL,'2026-08-24 11:14:05','2026-08-26 11:14:05'),(12,'DEMO-0003','demo-member-03','demo.member03@example.com','shipped','USD',6000,0,0,6000,NULL,NULL,NULL,'Michael Reed','+1 555 0100','United States',NULL,'Chicago',NULL,'3 Demo Street',NULL,NULL,'2026-08-27 11:14:05','2026-08-27 11:14:05','2026-09-18 13:36:01',NULL,'2026-09-16 13:36:01',NULL),(13,'DEMO-0004','demo-member-05','demo.member05@example.com','completed','USD',9000,0,0,9000,NULL,NULL,NULL,'佐藤 健','+1 555 0100','日本',NULL,'东京',NULL,'5 Demo Street',NULL,NULL,'2026-08-30 11:14:06','2026-08-30 11:14:06','2026-09-18 13:36:01',NULL,'2026-08-30 11:14:06','2026-09-01 11:14:06'),(14,'DEMO-0005','demo-member-06','demo.member06@example.com','paid','USD',2000,0,0,2000,NULL,NULL,NULL,'鈴木 美咲','+1 555 0100','日本',NULL,'大阪',NULL,'6 Demo Street',NULL,NULL,'2026-09-01 11:14:06','2026-09-01 11:14:06','2026-09-01 11:14:06',NULL,NULL,NULL),(15,'DEMO-0006','demo-member-08','demo.member08@example.com','completed','USD',7000,0,0,7000,NULL,NULL,NULL,'Lukas Weber','+1 555 0100','Germany',NULL,'Berlin',NULL,'8 Demo Street',NULL,NULL,'2026-09-04 11:14:06','2026-09-04 11:14:06','2026-09-18 13:36:01',NULL,'2026-09-04 11:14:06','2026-09-06 11:14:06'),(16,'DEMO-0007','demo-member-10','demo.member10@example.com','shipped','USD',10000,0,0,10000,NULL,NULL,NULL,'Oliver Smith','+1 555 0100','United Kingdom',NULL,'London',NULL,'10 Demo Street',NULL,NULL,'2026-09-06 11:14:06','2026-09-06 11:14:06','2026-09-18 13:36:01',NULL,'2026-09-16 13:36:01',NULL),(17,'DEMO-0008','demo-member-12','demo.member12@example.com','paid','USD',2500,0,0,2500,NULL,NULL,NULL,'Louis Martin','+1 555 0100','France',NULL,'Paris',NULL,'12 Demo Street',NULL,NULL,'2026-09-08 11:14:06','2026-09-08 11:14:06','2026-09-08 11:14:06',NULL,NULL,NULL),(18,'DEMO-0009','demo-member-14','demo.member14@example.com','completed','USD',1000,0,0,1000,NULL,NULL,NULL,'Noah Tremblay','+1 555 0100','Canada',NULL,'Toronto',NULL,'14 Demo Street',NULL,NULL,'2026-09-10 11:14:06','2026-09-10 11:14:06','2026-09-18 13:36:01',NULL,'2026-09-10 11:14:06','2026-09-12 11:14:06'),(19,'DEMO-0010','demo-member-15','demo.member15@example.com','shipped','USD',3000,0,0,3000,NULL,NULL,NULL,'Ava Gagnon','+1 555 0100','Canada',NULL,'Vancouver',NULL,'15 Demo Street',NULL,NULL,'2026-09-12 11:14:06','2026-09-12 11:14:06','2026-09-18 13:36:01',NULL,'2026-09-16 13:36:01',NULL),(20,'DEMO-0011','demo-member-17','demo.member17@example.com','paid','USD',6700,0,0,6700,NULL,NULL,NULL,'Wei Tan','+1 555 0100','Singapore',NULL,'Singapore',NULL,'17 Demo Street',NULL,NULL,'2026-09-14 11:14:06','2026-09-14 11:14:06','2026-09-14 11:14:06',NULL,NULL,NULL),(21,'DEMO-0012','demo-member-18','demo.member18@example.com','pending','USD',6000,0,0,6000,NULL,NULL,NULL,'Rafael Souza','+1 555 0100','Brazil',NULL,'Sao Paulo',NULL,'18 Demo Street',NULL,NULL,NULL,'2026-09-15 11:14:06','2026-09-15 11:14:06',NULL,NULL,NULL),(22,'DEMO-0013','demo-member-19','demo.member19@example.com','paid','USD',5000,0,0,5000,NULL,NULL,NULL,'김지훈','+1 555 0100','South Korea',NULL,'Seoul',NULL,'19 Demo Street',NULL,NULL,'2026-09-16 11:14:06','2026-09-16 11:14:06','2026-09-16 11:14:06',NULL,NULL,NULL),(23,'DEMO-0014','demo-member-20','demo.member20@example.com','pending','USD',7000,0,0,7000,NULL,NULL,NULL,'Lucía Fernández','+1 555 0100','Spain',NULL,'Madrid',NULL,'20 Demo Street',NULL,NULL,NULL,'2026-09-17 11:14:06','2026-09-17 11:14:06',NULL,NULL,NULL),(33,'UL20260918720959','UJZd1gQ2pUHHMAkoHHapNY9QW54yEile','test@abc.com','completed','USD',22200,0,0,22200,NULL,NULL,'fdsafdsafdasfdsa','fjdska','8493215432','中国','Sichuan, chengdu','fdsa','ewerw','Sichuan , Chengdu city,',NULL,'620500','2026-09-18 12:18:37','2026-09-18 12:18:27','2026-09-18 13:54:34','sf14232432',NULL,'2026-09-18 13:37:13'),(51,'UL20260918452672','UJZd1gQ2pUHHMAkoHHapNY9QW54yEile','test@abc.com','pending','USD',12500,0,0,12500,NULL,NULL,NULL,'fjdska','8493215432','中国','Sichuan, chengdu','fdsa','ewerw','Sichuan , Chengdu city,',NULL,'620500',NULL,'2026-09-18 20:29:03','2026-09-18 20:29:03',NULL,NULL,NULL),(52,'UL20260918771430','1wKpQRdHAxKWEvupzUVg1CPWEku04eAk','a@test.com','pending','USD',3000,0,990,3990,NULL,NULL,'hjb v','hfcch','4567874332','ghese','gcvj','gvvvb',NULL,'gcc. v',NULL,'ttfcc',NULL,'2026-09-18 20:33:30','2026-09-18 20:33:30',NULL,NULL,NULL),(53,'UL20260918056731','1wKpQRdHAxKWEvupzUVg1CPWEku04eAk','a@test.com','paid','USD',5000,0,990,5990,NULL,NULL,NULL,'hfcch','4567874332','ghese','gcvj','gvvvb',NULL,'gcc. v',NULL,'ttfcc','2026-09-18 21:58:47','2026-09-18 21:58:40','2026-09-18 21:58:46',NULL,NULL,NULL);
/*!40000 ALTER TABLE `orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `productAttributeValues`
--

DROP TABLE IF EXISTS `productAttributeValues`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `productAttributeValues` (
  `id` int NOT NULL AUTO_INCREMENT,
  `productId` int NOT NULL,
  `attributeId` int NOT NULL,
  `values` json NOT NULL DEFAULT (_utf8mb4'[]'),
  `createdAt` timestamp NOT NULL DEFAULT (now()),
  `updatedAt` timestamp NOT NULL DEFAULT (now()) ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_pav_product_attribute` (`productId`,`attributeId`),
  KEY `productAttributeValues_attributeId_productAttributes_id_fk` (`attributeId`),
  KEY `idx_pav_product` (`productId`),
  CONSTRAINT `productAttributeValues_attributeId_productAttributes_id_fk` FOREIGN KEY (`attributeId`) REFERENCES `productAttributes` (`id`) ON DELETE CASCADE,
  CONSTRAINT `productAttributeValues_productId_products_id_fk` FOREIGN KEY (`productId`) REFERENCES `products` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `productAttributeValues`
--

LOCK TABLES `productAttributeValues` WRITE;
/*!40000 ALTER TABLE `productAttributeValues` DISABLE KEYS */;
INSERT INTO `productAttributeValues` VALUES (1,25,1,'[\"Green\", \"Yellow\", \"Gray\", \"Blue\", \"Orange\"]','2026-09-16 17:36:00','2026-09-16 17:36:00'),(2,25,2,'[\"S\", \"M\", \"L\"]','2026-09-16 17:36:00','2026-09-16 17:36:00'),(3,28,1,'[\"Red\", \"Gray\", \"Silver\"]','2026-09-16 17:36:00','2026-09-16 17:36:00'),(4,28,2,'[\"S\", \"M\", \"L\"]','2026-09-16 17:36:00','2026-09-16 17:36:00'),(9,26,1,'[\"Silver\", \"Gray\"]','2026-09-17 16:18:25','2026-09-17 16:18:25'),(10,26,2,'[\"S\", \"M\"]','2026-09-17 16:18:25','2026-09-17 16:18:25'),(11,27,1,'[\"Blue\", \"Purple\", \"Green\"]','2026-09-17 16:18:25','2026-09-17 16:18:25'),(12,29,1,'[\"Black\", \"Gray\", \"Red\"]','2026-09-17 16:18:25','2026-09-17 16:18:25'),(13,30,2,'[\"100ml\"]','2026-09-17 16:18:25','2026-09-17 16:18:25'),(14,31,1,'[\"Blue\", \"Green\", \"Orange\"]','2026-09-17 16:18:25','2026-09-17 16:18:25'),(15,32,1,'[\"Green\", \"Yellow\"]','2026-09-17 16:18:25','2026-09-17 16:18:25'),(16,32,2,'[\"S\", \"M\", \"L\"]','2026-09-17 16:18:25','2026-09-17 16:18:25');
/*!40000 ALTER TABLE `productAttributeValues` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `productAttributes`
--

DROP TABLE IF EXISTS `productAttributes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `productAttributes` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `nameEn` varchar(100) DEFAULT NULL,
  `type` enum('swatch','text') NOT NULL DEFAULT 'text',
  `options` json NOT NULL DEFAULT (_utf8mb4'[]'),
  `sortOrder` int NOT NULL DEFAULT '0',
  `createdAt` timestamp NOT NULL DEFAULT (now()),
  `updatedAt` timestamp NOT NULL DEFAULT (now()) ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `productAttributes`
--

LOCK TABLES `productAttributes` WRITE;
/*!40000 ALTER TABLE `productAttributes` DISABLE KEYS */;
INSERT INTO `productAttributes` VALUES (1,'颜色','Color','swatch','[\"Green\", \"Yellow\", \"Gray\", \"Blue\", \"Orange\", \"Red\", \"Silver\", \"Black\", \"White\"]',1,'2026-09-16 17:36:00','2026-09-16 17:36:00'),(2,'尺码','Size','text','[\"XS\", \"S\", \"M\", \"L\"]',2,'2026-09-16 17:36:00','2026-09-17 13:05:03');
/*!40000 ALTER TABLE `productAttributes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `productReviews`
--

DROP TABLE IF EXISTS `productReviews`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `productReviews` (
  `id` int NOT NULL AUTO_INCREMENT,
  `productId` int NOT NULL,
  `userId` varchar(36) DEFAULT NULL,
  `authorName` varchar(100) NOT NULL,
  `rating` int NOT NULL DEFAULT '5',
  `title` varchar(150) DEFAULT NULL,
  `content` text NOT NULL,
  `status` enum('pending','approved','rejected') NOT NULL DEFAULT 'pending',
  `createdAt` timestamp NOT NULL DEFAULT (now()),
  `updatedAt` timestamp NOT NULL DEFAULT (now()) ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_reviews_product_user` (`productId`,`userId`),
  KEY `productReviews_userId_user_id_fk` (`userId`),
  KEY `idx_reviews_product_status` (`productId`,`status`),
  KEY `idx_reviews_status` (`status`),
  CONSTRAINT `productReviews_productId_products_id_fk` FOREIGN KEY (`productId`) REFERENCES `products` (`id`) ON DELETE CASCADE,
  CONSTRAINT `productReviews_userId_user_id_fk` FOREIGN KEY (`userId`) REFERENCES `user` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `productReviews`
--

LOCK TABLES `productReviews` WRITE;
/*!40000 ALTER TABLE `productReviews` DISABLE KEYS */;
/*!40000 ALTER TABLE `productReviews` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `products`
--

DROP TABLE IF EXISTS `products`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `products` (
  `id` int NOT NULL AUTO_INCREMENT,
  `code` varchar(32) NOT NULL,
  `categoryId` int DEFAULT NULL,
  `name` varchar(200) NOT NULL,
  `slug` varchar(220) NOT NULL,
  `description` text,
  `priceCents` int NOT NULL,
  `currency` varchar(3) NOT NULL DEFAULT 'USD',
  `images` json NOT NULL DEFAULT (_utf8mb4'[]'),
  `status` enum('draft','active','archived') NOT NULL DEFAULT 'draft',
  `createdAt` timestamp NOT NULL DEFAULT (now()),
  `updatedAt` timestamp NOT NULL DEFAULT (now()) ON UPDATE CURRENT_TIMESTAMP,
  `nameEn` varchar(200) DEFAULT NULL,
  `compareAtPriceCents` int DEFAULT NULL,
  `stock` int DEFAULT NULL,
  `viewCount` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `products_slug_unique` (`slug`),
  UNIQUE KEY `products_code_unique` (`code`),
  KEY `idx_products_categoryId` (`categoryId`),
  KEY `idx_products_status` (`status`),
  KEY `idx_products_name` (`name`),
  KEY `idx_products_viewCount` (`viewCount`),
  CONSTRAINT `products_categoryId_categories_id_fk` FOREIGN KEY (`categoryId`) REFERENCES `categories` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=34 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `products`
--

LOCK TABLES `products` WRITE;
/*!40000 ALTER TABLE `products` DISABLE KEYS */;
INSERT INTO `products` VALUES (25,'P0025',13,'Cyber X 烟弹系统套装','cyber-x-pod-system-kit','一体化烟弹系统，强劲口感与极简操作的完美结合。Type-C 快充，多重安全保护。',5000,'USD','[\"/images/products/cyber-x-pod.jpg\"]','active','2026-09-16 12:35:02','2026-09-18 21:58:40','Cyber X Pod System Kit',NULL,47,328),(26,'P0026',18,'可注油烟弹 2ml - 2 颗装','refillable-pods-2ml','2ml 容量可注油烟弹，兼容多款设备，独立密封包装。',2500,'USD','[\"/images/products/refillable-pods.jpg\"]','active','2026-09-16 12:35:02','2026-09-18 20:29:03','Refillable Pods 2ml - 2 x Pods',NULL,49,35),(27,'P0027',15,'Geek Bar Lite 一次性烟弹','geek-bar-lite-disposable-pod','便携一次性设计，开盖即用，多种人气口味可选。',2000,'USD','[\"/images/products/geek-bar-lite.jpg\"]','active','2026-09-16 12:35:02','2026-09-18 12:27:32','Geek Bar Lite Disposable Pod',NULL,50,65),(28,'P0028',13,'Level X Boost 设备套装','level-x-boost-device-kit','大功率可调输出，OLED 屏显，兼容多种雾化芯。',6700,'USD','[\"/images/products/level-x-boost.jpg\"]','active','2026-09-16 12:35:02','2026-09-18 12:27:32','Level X Boost Device Kit',7900,50,97),(29,'P0029',13,'Argus GT 2 入门套装 200w','argus-gt-2-starter-kit-200w','200W 大功率入门套装，IP68 三防机身，澎湃云雾。',7000,'USD','[\"/images/products/argus-gt2.jpg\"]','active','2026-09-16 12:35:02','2026-09-18 11:52:37','Argus GT 2 Starter Kit 200w',8000,50,18),(30,'P0030',14,'草莓 100ml 烟油','strawberry-100ml-vape-juice','100ml 大容量草莓口味，香甜多汁，顺滑不腻。',3000,'USD','[\"/images/products/strawberry-juice.jpg\"]','active','2026-09-16 12:35:02','2026-09-18 15:09:20','Strawberry 100ml Vape Juice',NULL,50,184),(31,'P0031',15,'Blue Bar 一次性电子烟套装','blue-bar-disposable-vape-kit','预注满烟油的一次性电子烟，开盖即用，口感强劲，多口味可选。',3000,'USD','[\"/images/products/blue-bar.jpg\"]','active','2026-09-16 15:46:51','2026-09-18 20:33:30','Blue Bar Disposable Vape Kit',NULL,2,245),(32,'P0032',18,'预注油烟弹套装','prefilled-disposable-pod-kit','预注油一体烟弹，磁吸连接即插即用，多口味可选，独立密封包装。',1000,'USD','[\"/images/products/prefilled-pod.jpg\", \"/images/products/prefilled-kit.jpg\", \"/images/products/prefilled-disposable.jpg\", \"/images/products/prefilled-liquid.jpg\"]','active','2026-09-16 15:46:51','2026-09-18 11:52:37','Prefilled Disposable Pod Kit',NULL,NULL,10);
/*!40000 ALTER TABLE `products` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `searchTerms`
--

DROP TABLE IF EXISTS `searchTerms`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `searchTerms` (
  `id` int NOT NULL AUTO_INCREMENT,
  `term` varchar(100) NOT NULL,
  `count` int NOT NULL DEFAULT '1',
  `createdAt` timestamp NOT NULL DEFAULT (now()),
  `updatedAt` timestamp NOT NULL DEFAULT (now()) ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `searchTerms_term_unique` (`term`),
  KEY `idx_searchTerms_count` (`count`)
) ENGINE=InnoDB AUTO_INCREMENT=109 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `searchTerms`
--

LOCK TABLES `searchTerms` WRITE;
/*!40000 ALTER TABLE `searchTerms` DISABLE KEYS */;
INSERT INTO `searchTerms` VALUES (1,'cyber',17,'2026-09-17 16:15:32','2026-09-17 16:28:12'),(2,'pod',9,'2026-09-17 16:15:32','2026-09-17 16:15:32'),(3,'juice',7,'2026-09-17 16:15:32','2026-09-17 16:15:32'),(4,'coil',5,'2026-09-17 16:15:32','2026-09-17 16:15:32'),(5,'kit',4,'2026-09-17 16:15:32','2026-09-17 16:15:32'),(6,'disposable',3,'2026-09-17 16:15:32','2026-09-17 16:15:32'),(17,'syber',1,'2026-09-17 16:27:59','2026-09-17 16:27:59');
/*!40000 ALTER TABLE `searchTerms` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `session`
--

DROP TABLE IF EXISTS `session`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `session` (
  `id` varchar(36) NOT NULL,
  `expiresAt` timestamp NOT NULL,
  `token` varchar(255) NOT NULL,
  `createdAt` timestamp NOT NULL DEFAULT (now()),
  `updatedAt` timestamp NOT NULL DEFAULT (now()) ON UPDATE CURRENT_TIMESTAMP,
  `ipAddress` varchar(255) DEFAULT NULL,
  `userAgent` text,
  `userId` varchar(36) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `session_token_unique` (`token`),
  KEY `idx_session_userId` (`userId`),
  CONSTRAINT `session_userId_user_id_fk` FOREIGN KEY (`userId`) REFERENCES `user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `session`
--

LOCK TABLES `session` WRITE;
/*!40000 ALTER TABLE `session` DISABLE KEYS */;
INSERT INTO `session` VALUES ('08bDU0Jq091MFBPhy4qpnPJAf77YdBRQ','2026-09-25 11:00:40','NprnwjT6t3kuMD8RvKkvIVMy53XVH72N','2026-09-18 11:00:40','2026-09-18 11:00:40','0000:0000:0000:0000:0000:0000:0000:0000','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('116xPfNZz1HQpkNhAdPpmTte87noNClw','2026-09-24 18:40:49','EWYYfu7gbcNsAVduQsPbVRR9cX7iv0tL','2026-09-17 18:40:49','2026-09-17 18:40:49','0000:0000:0000:0000:0000:0000:0000:0000','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('1GXIalirVTQSJOxu6yKRTdHbeGEnJTKo','2026-09-25 13:26:21','O22nvqxwA2DYGyKQ5bH9xix6ELxTuVms','2026-09-18 13:26:21','2026-09-18 13:26:21','0000:0000:0000:0000:0000:0000:0000:0000','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','rXi36d6MyI8p0fn8rRhZwMiR5GGA7SVT'),('1jimwQtjH1vqUmjSso5nck1mA07rBlEB','2026-09-25 12:07:39','sS4ci5idMAwsPccQR2PhuPXcUN8lxEar','2026-09-18 12:07:39','2026-09-18 12:07:39','0000:0000:0000:0000:0000:0000:0000:0000','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('1KdgP8VilgrIgqyC48ikQtjI4PJQMJDH','2026-09-25 17:52:48','v6oi0AdLV9E6KfzIFMWywIW6KM6f0sw3','2026-09-18 17:52:48','2026-09-18 17:52:48','43.198.248.55','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('22vei11KzE51EikC1pzVd54e4UA6HcIS','2026-09-24 14:44:54','lIyKn8HjD3SiAhjIQJahVNkxahuwpyGO','2026-09-17 14:44:54','2026-09-17 14:44:54','0000:0000:0000:0000:0000:0000:0000:0000','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('2GhtKniOJ6Da0XmNiFYo7Ipdl8fNSvGj','2026-09-25 13:34:49','4AafCk6NthZCjIihxScXSIQTCF39Hx4U','2026-09-18 13:34:49','2026-09-18 13:34:49','0000:0000:0000:0000:0000:0000:0000:0000','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','rXi36d6MyI8p0fn8rRhZwMiR5GGA7SVT'),('2pMztCwMCQFry3oqngE5XLimYsG4d3BY','2026-09-25 11:40:01','XWooJj5LhyLOVvSjrBK6P7eTwgvLEZIS','2026-09-18 11:40:01','2026-09-18 11:40:01','0000:0000:0000:0000:0000:0000:0000:0000','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('2viD1n7Me5k1EI8yJMsAj0inK2n4qfH0','2026-09-25 11:40:46','3j30YGF2BA9bZEYHvXbrNU1mlRSzOsoL','2026-09-18 11:40:46','2026-09-18 11:40:46','0000:0000:0000:0000:0000:0000:0000:0000','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('2xK0PM0rNXB0PtDMJzSoWG3vnOODm6yN','2026-09-24 18:46:27','BBH6F68cRKiz017P5aWz3vfkCAJOUvoQ','2026-09-17 18:46:27','2026-09-17 18:46:27','0000:0000:0000:0000:0000:0000:0000:0000','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('2Y5JkXC5V4pDWxfHzJZKbHtlTyJ5sMim','2026-09-25 13:36:40','fVmNHojZLtnvA27qNmML1RtaSFQcyfeN','2026-09-18 13:36:40','2026-09-18 13:36:40','0000:0000:0000:0000:0000:0000:0000:0000','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36','UJZd1gQ2pUHHMAkoHHapNY9QW54yEile'),('2ylr6VD8RcUxLJDZ7AxICHG0dbSY7SDP','2026-09-24 17:14:43','QzOGmoqEZuBkBgIFd0wxzPtOsUKhkoAl','2026-09-17 17:14:43','2026-09-17 17:14:43','0000:0000:0000:0000:0000:0000:0000:0000','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('3CoU6tz5YIFpq2kzbSSqWJ4hf1RR480N','2026-09-25 12:31:40','Q1OfTyYlxRsHFh15V90CnPZavWGNzNcF','2026-09-18 12:31:40','2026-09-18 12:31:40','0000:0000:0000:0000:0000:0000:0000:0000','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('47dMdttyrH6tgHqPQdzuiJunOcWdHUQG','2026-09-25 12:56:23','pjLWWoP4XEpK18DzeGlJ9Jfj2kd4rYrL','2026-09-18 12:56:23','2026-09-18 12:56:23','0000:0000:0000:0000:0000:0000:0000:0000','Bun/1.4.0','rXi36d6MyI8p0fn8rRhZwMiR5GGA7SVT'),('4Il4tuKNKPUglvREkfaKJgdN1JwZ31ME','2026-09-25 12:11:45','vkcTwUkIXQyGDL2FZJsu4rTHhgLiubaz','2026-09-18 12:11:45','2026-09-18 12:11:45','0000:0000:0000:0000:0000:0000:0000:0000','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('4IQUOgSt9UJHNe8TowWSL8WOAgZYRYX8','2026-09-25 12:22:32','l68MV9jwT1i5iAOYYg46TwcORxil89bn','2026-09-18 12:22:32','2026-09-18 12:22:32','0000:0000:0000:0000:0000:0000:0000:0000','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('55DJW5B3j9FY4MDVbvtNnOHtQ66Lu2Sp','2026-09-24 17:05:37','Vg2R5lHRwgr1Pmnaicg4HW91Wg6ea7o7','2026-09-17 17:05:37','2026-09-17 17:05:37','0000:0000:0000:0000:0000:0000:0000:0000','curl/8.7.1','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('5AFQvVv7LhRvCuyE2yEsewhfM6hjeKN6','2026-09-25 13:56:51','2I0zhCElK2ME4FnccQCZnzmmFhimzc0F','2026-09-18 13:56:51','2026-09-18 13:56:51','0000:0000:0000:0000:0000:0000:0000:0000','curl/8.7.1','rXi36d6MyI8p0fn8rRhZwMiR5GGA7SVT'),('6UptBUdKGE0Qea08OgziD8HWVRVjSPRu','2026-09-24 14:45:10','T1tclHvW7cY7c12ZqDd7u2dKvO6CXOnG','2026-09-17 14:45:10','2026-09-17 14:45:10','0000:0000:0000:0000:0000:0000:0000:0000','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('76p2RGyqx7Vtd2L37OUep7oCCDqJcea2','2026-09-25 11:51:36','GybyndU6xv9GnTeHhFYXakPtRv4bnv9O','2026-09-18 11:51:36','2026-09-18 11:51:36','0000:0000:0000:0000:0000:0000:0000:0000','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('7a0oqoL0Ub9HjiOyMYIdG4kZClZk1HNE','2026-09-24 18:40:31','vNfj7uXKDzrPtllJIApOJHazIq0oSo2p','2026-09-17 18:40:31','2026-09-17 18:40:31','0000:0000:0000:0000:0000:0000:0000:0000','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('7UIzfTvlVIYmesOYIX0XDqH7QaabqoF9','2026-09-25 11:06:12','FGYZbcbq62UCNQdB9axNiq4cGcf9c7dE','2026-09-18 11:06:12','2026-09-18 11:06:12','0000:0000:0000:0000:0000:0000:0000:0000','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('89JfocKOUtuQ3BStTa06mtrjXVuEFn4X','2026-09-25 11:41:01','SnuJpdT2eXHoRtNRsEqsgBegcnL8SO16','2026-09-18 11:41:01','2026-09-18 11:41:01','0000:0000:0000:0000:0000:0000:0000:0000','curl/8.7.1','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('8AUIGBTkjInYLfQFsG7DC7zC0YDGOtUO','2026-09-25 12:57:08','OoB3twquEEdldqymoHSFczol84eVG3sm','2026-09-18 12:57:08','2026-09-18 12:57:08','0000:0000:0000:0000:0000:0000:0000:0000','curl/8.7.1','rXi36d6MyI8p0fn8rRhZwMiR5GGA7SVT'),('8dbVDwYMJJecDXVCfW1wM78WGi3J7g6w','2026-09-25 13:44:35','7yPIgFEgYhFxMXmN9ZwCbC2dAvbSNCWA','2026-09-18 13:44:35','2026-09-18 13:44:35','0000:0000:0000:0000:0000:0000:0000:0000','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','rXi36d6MyI8p0fn8rRhZwMiR5GGA7SVT'),('8X4NpUgoioS9dTHlPFaxj0Fsgkcjaohn','2026-09-25 13:45:46','ZdwKcB6x0hnxRZuDFrFXDI2tfJ1k8plV','2026-09-18 13:45:46','2026-09-18 13:45:46','0000:0000:0000:0000:0000:0000:0000:0000','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','rXi36d6MyI8p0fn8rRhZwMiR5GGA7SVT'),('8zb4GRBL31x8TYW4twQHz3RXoelJF1oS','2026-09-25 11:50:43','1ehRvXxAneXuaGeeNHXHzbONR5AXUBpq','2026-09-18 11:50:43','2026-09-18 11:50:43','0000:0000:0000:0000:0000:0000:0000:0000','curl/8.7.1','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('97dRUuBey9spHEXuAAYOlSvmfm068XGl','2026-09-24 18:02:20','xwZELcyaIBniPB8eLN8PzBZczBKhojeD','2026-09-17 18:02:20','2026-09-17 18:02:20','0000:0000:0000:0000:0000:0000:0000:0000','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('9lgooehgtVBIoW2nT8AhzQoPZAlSJKm0','2026-09-25 12:06:09','gqxdto08JylH2oEuAVHWF7z8AZzIMuor','2026-09-18 12:06:09','2026-09-18 12:06:09','0000:0000:0000:0000:0000:0000:0000:0000','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('9wAuIfbNca0bwzwK4w4iPFcVMVZ6gNWA','2026-09-25 12:14:08','JD61GzIhUoE5TQYxdlUtX5Nn9vRbiZ2X','2026-09-18 12:14:08','2026-09-18 12:14:08','0000:0000:0000:0000:0000:0000:0000:0000','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('aer0jPJ1JPwW1U01vznldbiRY2vGcNPN','2026-09-25 12:07:05','lbfHETBD5LJy30hyjWYQV8OpWaKA3mdq','2026-09-18 12:07:05','2026-09-18 12:07:05','0000:0000:0000:0000:0000:0000:0000:0000','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('AkRHVdy1farMjzV98isYiEeDimZFFAwT','2026-09-25 14:24:43','Xu8L7c3UG4PwEMixdjcxenn6hnfZxSPk','2026-09-18 14:24:43','2026-09-18 14:24:43','0000:0000:0000:0000:0000:0000:0000:0000','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','rXi36d6MyI8p0fn8rRhZwMiR5GGA7SVT'),('aN0RwLZTttJkkG5TE0GcYS4vlCrJimiY','2026-09-25 13:23:10','6MwUgbY9R0vCrp0rmjfHBdNEjNItJSVX','2026-09-18 13:23:10','2026-09-18 13:23:10','0000:0000:0000:0000:0000:0000:0000:0000','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','rXi36d6MyI8p0fn8rRhZwMiR5GGA7SVT'),('axYFwm05uIo3nF9i7S7KgJW5fgHf9J5X','2026-09-25 17:52:19','e1TvCKd87OOIO3sExYv8XlBmGT9wIixz','2026-09-18 17:52:19','2026-09-18 17:52:19','43.198.248.55','curl/8.7.1','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('AYiUZoUHirXb6fTAP8wXgX4GNblwqq4O','2026-09-25 11:47:12','Q9s05wWJLuUpJHgiRwcFGk65hNDIxhXx','2026-09-18 11:47:12','2026-09-18 11:47:12','0000:0000:0000:0000:0000:0000:0000:0000','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('b0nkWpZbYsXvmpp4paL8aKli7yx9F1zD','2026-09-25 11:55:46','lRLd57gG8S0yRljcgrdBOY5EOjrrJ7MN','2026-09-18 11:55:46','2026-09-18 11:55:46','0000:0000:0000:0000:0000:0000:0000:0000','curl/8.7.1','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('bOCanJezPzHRtBnIlSYB4H8vq5QWHDvO','2026-09-24 12:22:23','XgkzuBpfTYifIUfHWJLHxAEiRL4W6NDu','2026-09-16 12:01:35','2026-09-17 12:22:23','0000:0000:0000:0000:0000:0000:0000:0000','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('bufwsuh0NOSDJM2wg9RTnWuMaXPA3E00','2026-09-24 18:35:58','MlNThxQjIQvgAEa6KxT4wKcyOK9Vds5Z','2026-09-17 18:35:58','2026-09-17 18:35:58','0000:0000:0000:0000:0000:0000:0000:0000','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('bvhMbmgXEIIIXNoklN9bj4rJ8QvPohBX','2026-09-25 12:13:29','qVdQlV9yA0nMkKRXvUD3x81sXVjKhqM2','2026-09-18 12:13:29','2026-09-18 12:13:29','0000:0000:0000:0000:0000:0000:0000:0000','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('BxNcDgheSoBEVfqziV8inxUTfeILjnnF','2026-09-25 13:52:21','Yin9FgL8eDqpiY9pw0Mhnx1mlPbXpUKa','2026-09-18 13:52:21','2026-09-18 13:52:21','0000:0000:0000:0000:0000:0000:0000:0000','curl/8.7.1','rXi36d6MyI8p0fn8rRhZwMiR5GGA7SVT'),('cOgokZ3aTwcMZd7McgDepxsgmZBBEMcf','2026-09-25 12:56:23','NwYD3oiI2BWDQ12soQqZaIwNMhJq2ozm','2026-09-18 12:56:23','2026-09-18 12:56:23','0000:0000:0000:0000:0000:0000:0000:0000','Bun/1.4.0','rXi36d6MyI8p0fn8rRhZwMiR5GGA7SVT'),('CTbhEbadQygoyOFFRkvcOaU3k69YYGdY','2026-09-25 11:08:02','LH1HNB3QBz7C29uWZB6NiHbImDsFE4ro','2026-09-18 11:08:02','2026-09-18 11:08:02','0000:0000:0000:0000:0000:0000:0000:0000','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('ddFxWbOuWvtjm66kmaDdAv8s9ZlnvK5c','2026-09-25 11:45:58','ABSQNjP6tZsEnn1idV2pFZwGZbca4sX1','2026-09-18 11:45:58','2026-09-18 11:45:58','0000:0000:0000:0000:0000:0000:0000:0000','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('DN7KOT21mPjRAf7TckMp1GFP1JccFjfu','2026-09-25 12:06:38','m0ehkB63bodlBHWM7PSbUmmyKhL91Sgf','2026-09-18 12:06:38','2026-09-18 12:06:38','0000:0000:0000:0000:0000:0000:0000:0000','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('dRJptieq6jnmsERVbzkIpMyuNNrpLswP','2026-09-26 07:10:58','P6fXwqwpjQpcCqALtojucBiAXEMDJreN','2026-09-19 07:10:58','2026-09-19 07:10:58','110.187.90.86','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/132.0.0.0 Safari/537.36','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('E45oYOgqh14OYJpa89BACoECV4cU6WhJ','2026-09-25 13:58:44','rmxPfJRTnTrfcV7NLuP9BWlYZ5hsKG5G','2026-09-18 13:58:44','2026-09-18 13:58:44','0000:0000:0000:0000:0000:0000:0000:0000','curl/8.7.1','rXi36d6MyI8p0fn8rRhZwMiR5GGA7SVT'),('eDjJs0Rg3gJXbF7ZK8uQa5S7IEepJyZQ','2026-09-25 13:15:21','N2VPNfnFcmNLbow47GyjIldO2PVp0C1X','2026-09-18 13:15:21','2026-09-18 13:15:21','0000:0000:0000:0000:0000:0000:0000:0000','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','rXi36d6MyI8p0fn8rRhZwMiR5GGA7SVT'),('EHjQLl7dBykVAaKfs892ekVDoZVVtLQ9','2026-09-25 12:11:02','NNq0ejJTqPat9jtVmjap3E72y0d0g1WR','2026-09-18 12:11:02','2026-09-18 12:11:02','0000:0000:0000:0000:0000:0000:0000:0000','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('EhRrhaQvqkJCwYpw0LkdTxAh8TJAQL3b','2026-09-25 15:35:45','ybJt6NW2ClVGdDKNqjYkO8NtLKk0ah7r','2026-09-18 15:35:45','2026-09-18 15:35:45','0000:0000:0000:0000:0000:0000:0000:0000','curl/8.7.1','rXi36d6MyI8p0fn8rRhZwMiR5GGA7SVT'),('EkfN3fNQOFnfVFvFfGjM833fIAqLKTO0','2026-09-25 14:03:57','XxRhl1JVrc91Z4ZIT20oWZB7bQZvK1Bv','2026-09-18 14:03:57','2026-09-18 14:03:57','0000:0000:0000:0000:0000:0000:0000:0000','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','rXi36d6MyI8p0fn8rRhZwMiR5GGA7SVT'),('ErAHabC1xlMlSRztxgj4ugKB52oxlCBT','2026-09-25 18:02:56','fpLAlUtnvjxxhNYmsSDRTdhxMDU4hMkA','2026-09-18 18:02:56','2026-09-18 18:02:56','43.198.248.55','curl/8.7.1','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('EREYmNNvIuALTFebbaybwMvM68ZQIUZS','2026-09-25 11:44:41','IlUv63D2lC3VNUpmTItf9pOMQDcVGOem','2026-09-18 11:44:41','2026-09-18 11:44:41','0000:0000:0000:0000:0000:0000:0000:0000','curl/8.7.1','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('eXh42jdM8X6AoNeIfKVlLv4DYxdKb3Sy','2026-09-25 11:39:32','7n34j12wbRZu2UhJI9azEWcdwwjf6cns','2026-09-18 11:39:32','2026-09-18 11:39:32','0000:0000:0000:0000:0000:0000:0000:0000','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('eZnzynxuHosfBoMj7L5mwCXrDpb1FJPB','2026-09-25 11:06:22','mTTc9R1UHPBFk4K15YSJdwsmE609QnOp','2026-09-18 11:06:22','2026-09-18 11:06:22','0000:0000:0000:0000:0000:0000:0000:0000','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('fczhqzbzIbwWgbi8lOyEnXxdqTlXwNBf','2026-09-25 17:50:19','2QcxU1EQaTyr6CCjdRlpnfN21BT2jkZ5','2026-09-18 17:50:19','2026-09-18 17:50:19','43.198.248.55','curl/8.7.1','rXi36d6MyI8p0fn8rRhZwMiR5GGA7SVT'),('fIQAPsnfU4nWUgarCbcvyrrWekDNSM6z','2026-09-24 18:17:21','fNXrkKDbc4Q4rTRIkjLnIAQMWWHQ9Ys0','2026-09-17 18:17:21','2026-09-17 18:17:21','0000:0000:0000:0000:0000:0000:0000:0000','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('FnBCNctm6sng7MGs0671qZeveRtZh4wZ','2026-09-25 14:03:17','MliZgxo7Hs6Q7l5JpupHTdCBPKpZliNs','2026-09-18 14:03:17','2026-09-18 14:03:17','0000:0000:0000:0000:0000:0000:0000:0000','curl/8.7.1','rXi36d6MyI8p0fn8rRhZwMiR5GGA7SVT'),('fOrkXp15nyAuWtNAdqurnNoHYH04O1hj','2026-09-25 12:43:27','Vob17ZmoSzAnCP09k2mexK1h7JMwiMuX','2026-09-18 12:43:27','2026-09-18 12:43:27','0000:0000:0000:0000:0000:0000:0000:0000','curl/8.7.1','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('fXmjX45Ex5ohwXlEEqhkXN1ruonUR0OZ','2026-09-25 11:01:08','YRan7OE4fE0843Tnxbf5RTh0Yl3Aqtb5','2026-09-18 11:01:08','2026-09-18 11:01:08','0000:0000:0000:0000:0000:0000:0000:0000','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('g3sf6E68Ath6In67PaSqtkZWts3oSYoU','2026-09-25 12:37:07','14Caas2ZKqXCgEycZk5DPqrK6XSp6nLT','2026-09-18 12:37:07','2026-09-18 12:37:07','0000:0000:0000:0000:0000:0000:0000:0000','curl/8.7.1','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('G75t2jUvt6OYT58gnZqxhZpvZKmEfU1I','2026-09-25 14:03:37','t2AZcJd9zFn7bLRNNyAxcIx8udnAVAZ4','2026-09-18 14:03:37','2026-09-18 14:03:37','0000:0000:0000:0000:0000:0000:0000:0000','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','rXi36d6MyI8p0fn8rRhZwMiR5GGA7SVT'),('gQwYLkjPcJxRWPK80zZTWma8LB25RR9g','2026-09-25 10:12:23','4SW9uobvlBlmriXNwo7nDzpHpTzQnvG6','2026-09-18 10:12:23','2026-09-18 10:12:23','0000:0000:0000:0000:0000:0000:0000:0000','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('gTQA1oa8UW2juwJkbmg5kET7M4lZFG85','2026-09-25 12:56:58','cTTM0ouKM3CtUdQQrirnhR21weMTzb6h','2026-09-18 12:56:58','2026-09-18 12:56:58','0000:0000:0000:0000:0000:0000:0000:0000','curl/8.7.1','rXi36d6MyI8p0fn8rRhZwMiR5GGA7SVT'),('HAx4TNv91rXmrBe9FA1i7kSxQkILDYO2','2026-09-25 11:48:05','SoOs6M7Iz01jR7dvruHhyPVaxrzD8fUB','2026-09-18 11:48:05','2026-09-18 11:48:05','0000:0000:0000:0000:0000:0000:0000:0000','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('Hr5qGUhObPObIOsMh06lIGwCmEBNv1kI','2026-09-24 18:17:42','pFY3gabxKf4ERKvt0Bh61thsaDYATx7U','2026-09-17 18:17:42','2026-09-17 18:17:42','0000:0000:0000:0000:0000:0000:0000:0000','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('HyNllnGfQxhnI85ng4dLl4jZ7GaaLdYc','2026-09-25 13:45:11','0uAKTgOKFm3B3assNSxVQgwzzoYX4eST','2026-09-18 13:45:11','2026-09-18 13:45:11','0000:0000:0000:0000:0000:0000:0000:0000','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','rXi36d6MyI8p0fn8rRhZwMiR5GGA7SVT'),('IDzZ1KJjPR1BKs8D3WWiNhgACkdFqzTF','2026-09-25 12:05:17','x2IdC2LXEHriF30H2Sizgm5btX7bt8Y9','2026-09-18 12:05:17','2026-09-18 12:05:17','0000:0000:0000:0000:0000:0000:0000:0000','curl/8.7.1','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('IIxC9ds4rVR9W4tE40OfG9qsQjCD6Dym','2026-09-25 11:21:53','DKDTRplMqSAOayUoZF8PnB0R4n9EbwoW','2026-09-18 11:21:53','2026-09-18 11:21:53','0000:0000:0000:0000:0000:0000:0000:0000','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('iOKFELgsBj8kIlskoqEr9EegXqcykVoE','2026-09-25 18:50:27','dnkQW1hRTwjKv9ybVBKV1VjQSFnMM1LX','2026-09-18 18:50:27','2026-09-18 18:50:27','183.223.133.201','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36','79UhVSTRB4Oh5ibyIoJfR2JqvkI5NXdb'),('JidWzSW97OtxqRLfGKpeRPooPn2xOS7j','2026-09-25 12:10:18','gvn4T2YMHTogefwmKA7IRUBvLJgwAUvG','2026-09-18 12:10:18','2026-09-18 12:10:18','0000:0000:0000:0000:0000:0000:0000:0000','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('JQ6hdq46bJoDJZiKMbHZWVr2KyjB7Yuu','2026-09-24 13:19:55','MhrJQtLXVSE3cFdepQutN5lV1f2EQM60','2026-09-17 13:19:55','2026-09-17 13:19:55','0000:0000:0000:0000:0000:0000:0000:0000','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('JvQSbkqsFn4D2KP1wMreKgxjTZGRyvNO','2026-09-24 14:32:33','MCpp0nME3euR3fxD6FU0OwCbdis9DcHe','2026-09-17 14:32:33','2026-09-17 14:32:33','0000:0000:0000:0000:0000:0000:0000:0000','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('Jw8YWIAxvaY0h9zBgx8GVR6lOSLY13lJ','2026-09-25 21:38:07','YGoraq25xwxXAznRWf1PgLRfIUT2WUCa','2026-09-18 21:38:07','2026-09-18 21:38:07','183.223.133.201','curl/8.7.1','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('KE8zcseWh2GwHWnJ2UOF3ntBrP2Q49i0','2026-09-25 11:07:52','n5hHCljt51i2lt0CwXboxVe2WXS8Ek5M','2026-09-18 11:07:52','2026-09-18 11:07:52','0000:0000:0000:0000:0000:0000:0000:0000','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('ktNilffw7Nt4FbOkLuK87hGvEwMonlN0','2026-09-25 11:26:11','qEQyZQe6ujnOUDD5svaIKo2u6cQWiDug','2026-09-18 11:26:11','2026-09-18 11:26:11','0000:0000:0000:0000:0000:0000:0000:0000','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('LIPnizdhtOJdzhsRFAd18opC4ELP2T6w','2026-09-24 13:29:21','s5rRW4pf1t1vHRy37Eud1h9ru9p4guaf','2026-09-17 13:29:21','2026-09-17 13:29:21','0000:0000:0000:0000:0000:0000:0000:0000','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('lTakPUOfYP1GEnQYYN56qDyEfhK7vYYD','2026-09-25 13:57:39','3NgB6LmqPQsNj4bS8y0SXpiq26Hbogxj','2026-09-18 13:57:39','2026-09-18 13:57:39','0000:0000:0000:0000:0000:0000:0000:0000','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','rXi36d6MyI8p0fn8rRhZwMiR5GGA7SVT'),('LZnQ4m8iWTGWSvbCnTiI5nlZks2ZSIBy','2026-09-24 17:15:31','Nlfyey6xfz4fWAfX4jHrpF4Ok2PHi3Ta','2026-09-17 17:15:31','2026-09-17 17:15:31','0000:0000:0000:0000:0000:0000:0000:0000','curl/8.7.1','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('mAu6wNFfbF6gXf5Yo6PZ1IH4Y5wDrgga','2026-09-25 11:51:08','nnW4pwuSuWcYWjCuWbkB6a6pgG0MrVY2','2026-09-18 11:51:08','2026-09-18 11:51:08','0000:0000:0000:0000:0000:0000:0000:0000','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('miPowEIGmPuCjPohGddJoprdWOdL7qf1','2026-09-25 12:26:33','JqrcfOgCpaw2IbzTY4OdiJdOyoySLLwV','2026-09-18 12:26:33','2026-09-18 12:26:33','0000:0000:0000:0000:0000:0000:0000:0000','curl/8.7.1','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('NOGNzbhoeIn4FBcJqOinz7se7r2e91HT','2026-09-25 12:55:38','3lCenZm6jSjKNoP9ZQWzKzRi9dlYOVWw','2026-09-18 12:55:38','2026-09-18 12:55:38','0000:0000:0000:0000:0000:0000:0000:0000','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('o9apHLTZXvpcjBEccBOh1CeTC4Fl9gWA','2026-09-25 11:56:18','5zY498t6JO8dirbtZHB8mIc0Nm4k0aE0','2026-09-18 11:56:18','2026-09-18 11:56:18','0000:0000:0000:0000:0000:0000:0000:0000','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('oxcYOLTUu4PqUr4YVbl4QfW3kcD9BLq3','2026-09-24 18:39:42','ZGa3KibGOyRbF6K9cV9Jlpd9R1kxWCVe','2026-09-17 18:39:42','2026-09-17 18:39:42','0000:0000:0000:0000:0000:0000:0000:0000','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('OYRhVoJ1xlr14qeU3ydn8pGAR0y1LIWb','2026-09-25 11:48:21','GouQzBqfiZi2RVGn1jujYRdJWWnTxH59','2026-09-18 11:48:21','2026-09-18 11:48:21','0000:0000:0000:0000:0000:0000:0000:0000','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('pDMFyxO1qSxSlTH3aM00BXAhAEHC55SK','2026-09-24 18:16:39','b82WDSPCOj9I0cvgM7cZkapZJ7nmGHaF','2026-09-17 18:16:39','2026-09-17 18:16:39','0000:0000:0000:0000:0000:0000:0000:0000','curl/8.7.1','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('pFogrv59AMFvI54nOCFJaON3XsewQIX0','2026-09-25 12:12:23','3U9NXJJQocaCpXb9XVUnB9yoaUd1lpaH','2026-09-18 12:12:23','2026-09-18 12:12:23','0000:0000:0000:0000:0000:0000:0000:0000','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('ph94UZ1dXQRCac580FnkBaN2Gf4QkPET','2026-09-25 13:43:57','0Ov7lr0ZbMncP1KlrtjXPWluHDin8Hmh','2026-09-18 13:43:57','2026-09-18 13:43:57','0000:0000:0000:0000:0000:0000:0000:0000','curl/8.7.1','rXi36d6MyI8p0fn8rRhZwMiR5GGA7SVT'),('Ppnt7v0JUTnT1IAGHWgccRVIJlc20Nrk','2026-09-24 14:43:59','hzkPKTc4mOocTh5vdALygcNpA7ZVsq7o','2026-09-17 14:43:59','2026-09-17 14:43:59','0000:0000:0000:0000:0000:0000:0000:0000','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('pqutbxD91EFG2ZNizkC5oSHwS2wrNyfk','2026-09-24 17:22:41','poBTZHbHOuLxM4UxD5jWL3GDT1WHuFND','2026-09-17 17:22:41','2026-09-17 17:22:41','0000:0000:0000:0000:0000:0000:0000:0000','curl/8.7.1','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('puf7I6MJggXg0JmHoIQrsC0lojnDmkDX','2026-09-24 17:24:55','dIRjonbmYOQzqMHmeOxRyxvrFz40Qgvr','2026-09-17 17:24:55','2026-09-17 17:24:55','0000:0000:0000:0000:0000:0000:0000:0000','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('PWXYJYlpU5UBqHVXGfWZxJ8TplD9wO8l','2026-09-25 12:39:24','2k1Exkd97hGZM16xIYXcULMXGMPoa0fT','2026-09-18 12:39:24','2026-09-18 12:39:24','0000:0000:0000:0000:0000:0000:0000:0000','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('q3HGjGr1nNbf9RoFFqYGNDY9HBSk9X9E','2026-09-24 17:15:16','As0K31HrrmIaGAiAQUryqW8oW60BPUmQ','2026-09-17 17:15:16','2026-09-17 17:15:16','0000:0000:0000:0000:0000:0000:0000:0000','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('QdHlEc8kmqXRr1HmXx4zB7y3Aluj39QE','2026-09-25 10:12:52','S7vBwPEIHdlFEq02haE4rG8QNKpvIdpx','2026-09-18 10:12:52','2026-09-18 10:12:52','0000:0000:0000:0000:0000:0000:0000:0000','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('qQYovrLPm6H80fG6dvLQDPsIVE8bi9RO','2026-09-25 11:11:14','iMjDef1uAhH4kVAQJKLLr1P02U54AaB4','2026-09-18 11:11:14','2026-09-18 11:11:14','0000:0000:0000:0000:0000:0000:0000:0000','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('r1rufAxy3lIMOUgfJBGZCEfeyndQ2Q0e','2026-09-24 18:46:44','4MVnAVUowM2veiIRIdyDRjfXFaJJns7E','2026-09-17 18:46:44','2026-09-17 18:46:44','0000:0000:0000:0000:0000:0000:0000:0000','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('RcEQyaav031vUFRqLjGDANU8xU9utF0z','2026-09-25 11:24:46','wOCARAPUOzLqUzAKfPvT8SbITWzjfkzA','2026-09-18 11:24:46','2026-09-18 11:24:46','0000:0000:0000:0000:0000:0000:0000:0000','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('RHvT5RxizIWifULWIkt9W7yuapAZhni8','2026-09-25 12:44:23','LrcBPL9iQKvlSaKlTK5VIYt8mUWBC1yo','2026-09-18 12:44:23','2026-09-18 12:44:23','0000:0000:0000:0000:0000:0000:0000:0000','curl/8.7.1','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('Rnq7JKpVVFBKrV5szUHsBXCgWsMRABQs','2026-09-25 13:34:21','OCfbEEAjuWAANLCNAooGyqur0s5drHPb','2026-09-18 13:34:21','2026-09-18 13:34:21','0000:0000:0000:0000:0000:0000:0000:0000','curl/8.7.1','rXi36d6MyI8p0fn8rRhZwMiR5GGA7SVT'),('RTODbuZ9qrQmstaywYPjqB9UYU45ERrs','2026-09-25 14:21:20','80GH6siPs8K93uTlLhE94MkDI5ixXyhY','2026-09-18 14:21:20','2026-09-18 14:21:20','0000:0000:0000:0000:0000:0000:0000:0000','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','rXi36d6MyI8p0fn8rRhZwMiR5GGA7SVT'),('rvX98ZV3deLEfa3ahzZaJiadiE3HmCX7','2026-09-25 17:52:32','3E6EXcLfV3hNaJEA10589BC34JvVOKMj','2026-09-18 17:52:32','2026-09-18 17:52:32','43.198.248.55','curl/8.7.1','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('RWq4lCxGPdpzGX8vFPCrN0V3nF23C2ht','2026-09-25 11:45:06','TlN9jHduo8kk2OW65pz2uz3HD3YG3K8F','2026-09-18 11:45:06','2026-09-18 11:45:06','0000:0000:0000:0000:0000:0000:0000:0000','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('S3AvSAvWgohSYZtTZmiOM7ixnBn9WJLo','2026-09-25 12:37:34','8wHVUbt0XcnB1meHhDULASEH6fqc8pxB','2026-09-18 12:37:34','2026-09-18 12:37:34','0000:0000:0000:0000:0000:0000:0000:0000','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('S5aFP21BDQFlrm2HeMYTeMeai3WJe3AT','2026-09-25 17:56:22','V3PcMzKMZnC9G2ojjZ5y761qYWlruH3n','2026-09-18 17:56:22','2026-09-18 17:56:22','43.198.248.55','curl/8.7.1','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('skK3ZhRP6gFEz8jG6iv32vftJP8yFNDk','2026-09-25 12:27:07','n20Z3BjGHLvUNto2CGzvfeDmRaPCS7Un','2026-09-18 12:27:07','2026-09-18 12:27:07','0000:0000:0000:0000:0000:0000:0000:0000','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('sMNerbsD52Rq7A6INMjlGxc2GeWs3YlG','2026-09-25 17:52:19','sy8rtjmBKCI6nYqxET4yNf1DKEFf1I7K','2026-09-18 17:52:19','2026-09-18 17:52:19','43.198.248.55','curl/8.7.1','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('SwKJTnpSBKMNvSCzyVPgkm39rbznDdhC','2026-09-24 17:24:20','qv61ZToYAozTthtwEp2i68BtzfC3rays','2026-09-17 17:24:20','2026-09-17 17:24:20','0000:0000:0000:0000:0000:0000:0000:0000','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('sz4tpTLAUCatr9WtldeEJOmMxuCzWtDI','2026-09-24 14:44:33','2yyckoNIIfM4X6oQawNmMtpRrY39N30X','2026-09-17 14:44:33','2026-09-17 14:44:33','0000:0000:0000:0000:0000:0000:0000:0000','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('tL6G1AG4Ex9KMLxlMhypjLqeebTdBFKK','2026-09-25 12:17:11','kpSqu2Yrk60wo7GRELDOcF2qurReEeJb','2026-09-18 12:17:11','2026-09-18 12:17:11','0000:0000:0000:0000:0000:0000:0000:0000','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('Tomwhb9XegyR1tci3UrCwokzCaDWHRAH','2026-09-25 11:46:38','6IMYmmyRz7Pcz6tweiww45SkFJsxHt4B','2026-09-18 11:46:38','2026-09-18 11:46:38','0000:0000:0000:0000:0000:0000:0000:0000','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('tQpyWZZRlvtUMdVOHe6dGBOAFGJlfVRz','2026-09-25 11:41:18','DqntkIpwrI2fXFFcO7sRPm3kckvCgoXZ','2026-09-18 11:41:18','2026-09-18 11:41:18','0000:0000:0000:0000:0000:0000:0000:0000','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('u9bXfwzuOYoHXXVoDuuNSpujQUMB1cAG','2026-09-24 17:23:40','Raqzl6kII9QSwitogRJyX94l7xQonFF9','2026-09-17 17:23:40','2026-09-17 17:23:40','0000:0000:0000:0000:0000:0000:0000:0000','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('UcyskJly5jR0Q2Hz5Cu0giTH6EElerKE','2026-09-25 21:09:27','QJJiZccHI09wmAiCW0szCn6RBcXr5XUk','2026-09-18 21:09:27','2026-09-18 21:09:27','183.223.133.201','curl/8.7.1','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('Ue8J2oodbZgJFqHZMsvIMrRqQutmuEvI','2026-09-25 12:56:52','fzdAw6NUw9yJQlZQm4793snIuwgdYI6H','2026-09-18 12:56:52','2026-09-18 12:56:52','0000:0000:0000:0000:0000:0000:0000:0000','curl/8.7.1','rXi36d6MyI8p0fn8rRhZwMiR5GGA7SVT'),('uN2yxe9AGGgela8vz9dcavsZcPHk99qB','2026-09-25 11:09:53','6KihAfZT3AqnbJ5pwBmbFRDyH4L3jJ5W','2026-09-18 11:09:53','2026-09-18 11:09:53','0000:0000:0000:0000:0000:0000:0000:0000','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('UnoKqjpnvtk0CWWKPO9ftGLrRSxUGm5l','2026-09-24 18:09:58','ddf0z81COMjGA69fdklvWQugSjkCzPx6','2026-09-17 18:09:58','2026-09-17 18:09:58','0000:0000:0000:0000:0000:0000:0000:0000','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('UOwiDkLOBTK4lDVbkID5f1YtM01ASO31','2026-09-25 14:21:26','VMsU9Gp3tH1Q2XwqznaYzx3qsVOzSvjo','2026-09-18 14:21:26','2026-09-18 14:21:26','0000:0000:0000:0000:0000:0000:0000:0000','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36','UJZd1gQ2pUHHMAkoHHapNY9QW54yEile'),('VtcJeYm2FRhIYXxPyNAx1mmBVxwlpYg0','2026-09-25 12:31:33','uDeqGTv8J5N9ZBPF8oz6l5AKiqu3YOvA','2026-09-18 12:31:33','2026-09-18 12:31:33','0000:0000:0000:0000:0000:0000:0000:0000','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('w112p9M0DHYoNKrPReJR0VsQ0oN61Svl','2026-09-25 11:21:05','9Hqa1OXJ8KRfWMseMP2bTZZ7taukiU9V','2026-09-18 11:21:05','2026-09-18 11:21:05','0000:0000:0000:0000:0000:0000:0000:0000','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('w7bDoz7Yy7fxMKDFaHjAWAyYTImCgnZa','2026-09-25 13:52:19','qro6KI6khRUnumTSPI7sQe0roeUDPcm7','2026-09-18 13:52:19','2026-09-18 13:52:19','0000:0000:0000:0000:0000:0000:0000:0000','curl/8.7.1','rXi36d6MyI8p0fn8rRhZwMiR5GGA7SVT'),('Wfsu2JOx9qeRYBLkqbV1uIT8HqAvMItM','2026-09-25 14:24:16','90Y1UIsD9tIEeWMhWF12IQlyMfx8Yq4b','2026-09-18 14:24:16','2026-09-18 14:24:16','0000:0000:0000:0000:0000:0000:0000:0000','curl/8.7.1','rXi36d6MyI8p0fn8rRhZwMiR5GGA7SVT'),('wxZ4XnnF6xHwCvkQAXsDXJ6cz8aWawj0','2026-09-25 12:08:10','wF75y2GZWkSsvcbZ9k8aQXjNm86m09Ii','2026-09-18 12:08:10','2026-09-18 12:08:10','0000:0000:0000:0000:0000:0000:0000:0000','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('X0Najc2GvQdUQ7iYNnZpoVLSvvQQUE90','2026-09-25 12:57:57','aXpVcQNc60mJn9hvRjELdnoiuR6DbNrH','2026-09-18 12:57:57','2026-09-18 12:57:57','0000:0000:0000:0000:0000:0000:0000:0000','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','rXi36d6MyI8p0fn8rRhZwMiR5GGA7SVT'),('X2D9W69XeLxG6uvYTf50Xd01ZQkPCJdF','2026-09-25 12:58:15','l6skiGOMVkF0iPCj7ClCNNmoYLduIpE8','2026-09-18 12:58:15','2026-09-18 12:58:15','0000:0000:0000:0000:0000:0000:0000:0000','curl/8.7.1','rXi36d6MyI8p0fn8rRhZwMiR5GGA7SVT'),('xG76CJ2V90NAqlcuSaYNuNB18DPu7gBg','2026-09-25 11:14:51','8TqEoKdWpeeHh4l1VbToDOmh0bXaFrg7','2026-09-18 11:14:51','2026-09-18 11:14:51','0000:0000:0000:0000:0000:0000:0000:0000','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('XZo4gOP14zSUVp8GezfCZKZZYUe1r7ku','2026-09-25 20:31:36','sAM80EhZH3Z3GiLCjhEBPIhAcGV3HjdV','2026-09-18 20:31:36','2026-09-18 20:31:36','183.223.133.201','Mozilla/5.0 (iPhone; CPU iPhone OS 26_4_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/153.0.8010.24 Mobile/15E148 Safari/604.1','1wKpQRdHAxKWEvupzUVg1CPWEku04eAk'),('Y1NBkBAjLiWOKp4elmCNHZ711rkpLlWo','2026-09-25 11:46:12','ICXZgoXzJ2yF3368ZPvMzESk9MutU09h','2026-09-18 11:46:12','2026-09-18 11:46:12','0000:0000:0000:0000:0000:0000:0000:0000','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('y9gkSFlGcXNBj2sH1DAuRlxMkZhMj5WT','2026-09-25 15:12:56','Fj2YLvmYkjFaEtaGukWQhGawuzWKmvmN','2026-09-18 15:12:56','2026-09-18 15:12:56','0000:0000:0000:0000:0000:0000:0000:0000','curl/8.7.1','rXi36d6MyI8p0fn8rRhZwMiR5GGA7SVT'),('YKehC3E5ZDJd0LfnJoVFPZDU3soMZDcX','2026-09-25 11:45:34','twl3FebdJ1vCGZlpzBkzj3BlC2DPeHWL','2026-09-18 11:45:34','2026-09-18 11:45:34','0000:0000:0000:0000:0000:0000:0000:0000','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('YL4H81yDAvC3Y8kszuKtIxCfmSK9mRXy','2026-09-24 18:36:33','AjBWEdr5XoIX0My1lhTim0vlE77iv8RW','2026-09-17 18:36:33','2026-09-17 18:36:33','0000:0000:0000:0000:0000:0000:0000:0000','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('YlhG5N51xdbTRXaK5nDjZsgydx8w8wa0','2026-09-24 14:32:10','y53IVeK5ufnqKevDTmasaKcyXiXHmj2M','2026-09-17 14:32:10','2026-09-17 14:32:10','0000:0000:0000:0000:0000:0000:0000:0000','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('yTStb6azvBEWEaaQ2TNrumU5ynXiqVTx','2026-09-25 11:48:42','RYuafOVjepaIJdLPJHMP4VsjlxFjLjJW','2026-09-18 11:48:42','2026-09-18 11:48:42','0000:0000:0000:0000:0000:0000:0000:0000','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('YuSHeljx7NX44rkHmpqEM3NZv5B7ERpf','2026-09-25 11:40:22','9jclYfryficduC9cXDOqteIoRAJFdh8U','2026-09-18 11:40:22','2026-09-18 11:40:22','0000:0000:0000:0000:0000:0000:0000:0000','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('ZaRL9c99oLYgeRYQstlanoF4ZJLqMsJW','2026-09-25 10:12:01','eNULp21YyuuBkjcPxnJVIOVauNToospG','2026-09-18 10:12:01','2026-09-18 10:12:01','0000:0000:0000:0000:0000:0000:0000:0000','curl/8.7.1','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('zg6KJZ2MuteE3WBqIbPzvp37frjZ7b3Z','2026-09-24 13:14:12','1eJzcMCWikc4u7db3EnBySeRhsmZcQtr','2026-09-17 13:14:12','2026-09-17 13:14:12','0000:0000:0000:0000:0000:0000:0000:0000','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('Zg7mzbVCafuR3tsYxsuOUVHb2sFFsYXl','2026-09-24 17:06:26','Jkjr48KXsHrQO5kHYHd4417GvXEKeEBz','2026-09-17 17:06:26','2026-09-17 17:06:26','0000:0000:0000:0000:0000:0000:0000:0000','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('zgZijJrjTucJy9N7wUkk7IA5L7nj8UGn','2026-09-23 11:50:12','7bhV0nlF18K93coGS8qxPGXBYeUfhdwa','2026-09-16 11:50:12','2026-09-16 11:50:12','0000:0000:0000:0000:0000:0000:0000:0000','curl/8.7.1','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('ZiDjryYYfQlxGB2ALQmUfsoo7EbPLBax','2026-09-24 14:39:35','E0lH82l5ANjf0sOl9AvrjHNJvReO3Lb3','2026-09-17 14:39:35','2026-09-17 14:39:35','0000:0000:0000:0000:0000:0000:0000:0000','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('ZJXTDgpDgkjQGjY6MijU2CwqNaDdmPw5','2026-09-24 17:06:05','hkf7U1RTOaiT1Qq9ochqEVknabLseP0E','2026-09-17 17:06:05','2026-09-17 17:06:05','0000:0000:0000:0000:0000:0000:0000:0000','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6'),('ZOoIIfCqkzHs8zAYZCHgyaY29b1NGXT1','2026-09-24 17:06:39','teVf8rlkCvgqcXwlhcvSq2MqGoAbxU33','2026-09-17 17:06:39','2026-09-17 17:06:39','0000:0000:0000:0000:0000:0000:0000:0000','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/153.0.0.0 Safari/537.36','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6');
/*!40000 ALTER TABLE `session` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `site_settings`
--

DROP TABLE IF EXISTS `site_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `site_settings` (
  `key` varchar(64) NOT NULL,
  `value` text,
  `group` varchar(32) NOT NULL DEFAULT 'general',
  `label` varchar(100) DEFAULT NULL,
  `updatedAt` timestamp NOT NULL DEFAULT (now()) ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`key`),
  KEY `idx_site_settings_group` (`group`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `site_settings`
--

LOCK TABLES `site_settings` WRITE;
/*!40000 ALTER TABLE `site_settings` DISABLE KEYS */;
/*!40000 ALTER TABLE `site_settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `twoFactor`
--

DROP TABLE IF EXISTS `twoFactor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `twoFactor` (
  `id` varchar(36) NOT NULL,
  `secret` text NOT NULL,
  `backupCodes` text NOT NULL,
  `userId` varchar(36) NOT NULL,
  `verified` tinyint(1) NOT NULL DEFAULT '1',
  `failedVerificationCount` int NOT NULL DEFAULT '0',
  `lockedUntil` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `twoFactor_userId_user_id_fk` (`userId`),
  CONSTRAINT `twoFactor_userId_user_id_fk` FOREIGN KEY (`userId`) REFERENCES `user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `twoFactor`
--

LOCK TABLES `twoFactor` WRITE;
/*!40000 ALTER TABLE `twoFactor` DISABLE KEYS */;
/*!40000 ALTER TABLE `twoFactor` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user`
--

DROP TABLE IF EXISTS `user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user` (
  `id` varchar(36) NOT NULL,
  `name` text,
  `email` varchar(255) NOT NULL,
  `emailVerified` tinyint(1) NOT NULL DEFAULT '0',
  `image` text,
  `role` varchar(16) NOT NULL DEFAULT 'customer',
  `createdAt` timestamp NOT NULL DEFAULT (now()),
  `updatedAt` timestamp NOT NULL DEFAULT (now()) ON UPDATE CURRENT_TIMESTAMP,
  `phone` varchar(32) DEFAULT NULL,
  `signupIp` varchar(45) DEFAULT NULL,
  `signupCountry` varchar(64) DEFAULT NULL,
  `signupCity` varchar(100) DEFAULT NULL,
  `lastLoginIp` varchar(45) DEFAULT NULL,
  `lastLoginCountry` varchar(64) DEFAULT NULL,
  `lastLoginAt` timestamp NULL DEFAULT NULL,
  `signupCountryCode` varchar(8) DEFAULT NULL,
  `lastLoginCountryCode` varchar(8) DEFAULT NULL,
  `twoFactorEnabled` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_email_unique` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user`
--

LOCK TABLES `user` WRITE;
/*!40000 ALTER TABLE `user` DISABLE KEYS */;
INSERT INTO `user` VALUES ('1wKpQRdHAxKWEvupzUVg1CPWEku04eAk','li wei6666','a@test.com',0,NULL,'customer','2026-09-18 20:31:36','2026-09-18 22:00:16','44566643227777','183.223.133.201',NULL,NULL,'183.223.133.201',NULL,'2026-09-18 20:31:36',NULL,NULL,0),('79UhVSTRB4Oh5ibyIoJfR2JqvkI5NXdb','test','test@test.com',1,NULL,'admin','2026-09-18 15:29:23','2026-09-18 18:50:26',NULL,NULL,NULL,NULL,'183.223.133.201',NULL,'2026-09-18 18:50:27',NULL,NULL,0),('demo-member-01','James Carter','demo.member01@example.com',1,NULL,'customer','2026-06-30 15:37:23','2026-06-30 15:37:23',NULL,'104.28.12.31','United States','New York','104.28.12.31','United States','2026-07-01 15:37:23','US','US',0),('demo-member-02','Sophia Bennett','demo.member02@example.com',1,NULL,'customer','2026-07-04 15:37:23','2026-07-04 15:37:23',NULL,'104.28.13.7','United States','Los Angeles','104.28.13.7','United States','2026-07-06 15:37:23','US','US',0),('demo-member-03','Michael Reed','demo.member03@example.com',1,NULL,'customer','2026-07-08 15:37:23','2026-07-08 15:37:23',NULL,'104.28.14.19','United States','Chicago','104.28.14.19','United States','2026-07-11 15:37:23','US','US',0),('demo-member-04','Emily Harper','demo.member04@example.com',1,NULL,'customer','2026-07-12 15:37:23','2026-07-12 15:37:23',NULL,'104.28.15.44','United States','Austin','104.28.15.44','United States','2026-07-16 15:37:23','US','US',0),('demo-member-05','佐藤 健','demo.member05@example.com',1,NULL,'customer','2026-07-16 15:37:23','2026-07-16 15:37:23',NULL,'133.130.20.11','日本','东京','133.130.20.11','日本','2026-07-21 15:37:23','JP','JP',0),('demo-member-06','鈴木 美咲','demo.member06@example.com',1,NULL,'customer','2026-07-20 15:37:23','2026-07-20 15:37:23',NULL,'133.130.21.35','日本','大阪','133.130.21.35','日本','2026-07-21 15:37:23','JP','JP',0),('demo-member-07','高橋 悠','demo.member07@example.com',1,NULL,'customer','2026-07-24 15:37:23','2026-07-24 15:37:23',NULL,'133.130.22.9','日本','名古屋','133.130.22.9','日本','2026-07-26 15:37:23','JP','JP',0),('demo-member-08','Lukas Weber','demo.member08@example.com',1,NULL,'customer','2026-07-28 15:37:23','2026-07-28 15:37:23',NULL,'85.214.10.23','Germany','Berlin','85.214.10.23','Germany','2026-07-31 15:37:23','DE','DE',0),('demo-member-09','Anna Schmidt','demo.member09@example.com',1,NULL,'customer','2026-08-01 15:37:23','2026-08-01 15:37:23',NULL,'85.214.11.56','Germany','Munich','85.214.11.56','Germany','2026-08-05 15:37:23','DE','DE',0),('demo-member-10','Oliver Smith','demo.member10@example.com',1,NULL,'customer','2026-08-05 15:37:23','2026-08-05 15:37:23',NULL,'51.140.20.8','United Kingdom','London','51.140.20.8','United Kingdom','2026-08-10 15:37:23','GB','GB',0),('demo-member-11','Charlotte Brown','demo.member11@example.com',1,NULL,'customer','2026-08-09 15:37:23','2026-08-09 15:37:23',NULL,'51.140.21.77','United Kingdom','Manchester','51.140.21.77','United Kingdom','2026-08-10 15:37:23','GB','GB',0),('demo-member-12','Louis Martin','demo.member12@example.com',1,NULL,'customer','2026-08-13 15:37:23','2026-08-13 15:37:23',NULL,'92.222.30.14','France','Paris','92.222.30.14','France','2026-08-15 15:37:23','FR','FR',0),('demo-member-13','Camille Dubois','demo.member13@example.com',1,NULL,'customer','2026-08-17 15:37:23','2026-08-17 15:37:23',NULL,'92.222.31.28','France','Lyon','92.222.31.28','France','2026-08-20 15:37:23','FR','FR',0),('demo-member-14','Noah Tremblay','demo.member14@example.com',1,NULL,'customer','2026-08-21 15:37:23','2026-08-21 15:37:23',NULL,'99.79.10.5','Canada','Toronto','99.79.10.5','Canada','2026-08-25 15:37:23','CA','CA',0),('demo-member-15','Ava Gagnon','demo.member15@example.com',1,NULL,'customer','2026-08-25 15:37:23','2026-08-25 15:37:23',NULL,'99.79.11.62','Canada','Vancouver','99.79.11.62','Canada','2026-08-30 15:37:23','CA','CA',0),('demo-member-16','Jack Wilson','demo.member16@example.com',1,NULL,'customer','2026-08-29 15:37:23','2026-08-29 15:37:23',NULL,'13.236.20.19','Australia','Sydney','13.236.20.19','Australia','2026-08-30 15:37:23','AU','AU',0),('demo-member-17','Wei Tan','demo.member17@example.com',1,NULL,'customer','2026-09-02 15:37:23','2026-09-02 15:37:23',NULL,'128.199.30.7','Singapore','Singapore','128.199.30.7','Singapore','2026-09-04 15:37:23','SG','SG',0),('demo-member-18','Rafael Souza','demo.member18@example.com',1,NULL,'customer','2026-09-06 15:37:23','2026-09-06 15:37:23',NULL,'177.54.10.33','Brazil','Sao Paulo','177.54.10.33','Brazil','2026-09-09 15:37:23','BR','BR',0),('demo-member-19','김지훈','demo.member19@example.com',1,NULL,'customer','2026-09-10 15:37:23','2026-09-10 15:37:23',NULL,'175.106.20.44','South Korea','Seoul','175.106.20.44','South Korea','2026-09-14 15:37:23','KR','KR',0),('demo-member-20','Lucía Fernández','demo.member20@example.com',1,NULL,'customer','2026-09-14 15:37:23','2026-09-14 15:37:23',NULL,'88.16.30.21','Spain','Madrid','88.16.30.21','Spain','2026-09-19 15:37:23','ES','ES',0),('MtTk43nCRWicn9XwqYobCc2DIU2uqbI6','Admin','admin@uilines.dev',1,NULL,'admin','2026-09-16 11:46:52','2026-09-19 07:10:57',NULL,NULL,NULL,NULL,'110.187.90.86',NULL,'2026-09-19 07:10:58',NULL,NULL,0),('rXi36d6MyI8p0fn8rRhZwMiR5GGA7SVT','Test Admin','test@uilines.dev',1,NULL,'admin','2026-09-17 14:46:59','2026-09-18 17:50:18',NULL,NULL,NULL,NULL,'43.198.248.55',NULL,'2026-09-18 17:50:19',NULL,NULL,0),('UJZd1gQ2pUHHMAkoHHapNY9QW54yEile','test test','test@abc.com',0,NULL,'customer','2026-09-18 12:16:20','2026-09-18 21:37:48',NULL,'::1',NULL,NULL,'183.223.133.201',NULL,'2026-09-18 21:37:49',NULL,NULL,0);
/*!40000 ALTER TABLE `user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `verification`
--

DROP TABLE IF EXISTS `verification`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `verification` (
  `id` varchar(36) NOT NULL,
  `identifier` varchar(255) NOT NULL,
  `value` varchar(255) NOT NULL,
  `expiresAt` timestamp NOT NULL,
  `createdAt` timestamp NULL DEFAULT (now()),
  `updatedAt` timestamp NULL DEFAULT (now()) ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_verification_identifier` (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `verification`
--

LOCK TABLES `verification` WRITE;
/*!40000 ALTER TABLE `verification` DISABLE KEYS */;
INSERT INTO `verification` VALUES ('OT6OO7J08hOpynXTrJpf5hKPt8exmqLw','2fa-jQQ9HkPD14-oFUUk-ft7','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6','2026-09-18 18:00:40','2026-09-18 17:50:40','2026-09-18 17:50:40'),('QcDUBdmit7KCLTlmhccqSTvdRUH9U704','2fa-nF0oDkC9tScM7s5yhDlI','MtTk43nCRWicn9XwqYobCc2DIU2uqbI6','2026-09-18 18:00:20','2026-09-18 17:50:20','2026-09-18 17:50:20'),('QLZnbkJU0SEI4DGovFmi0tyA2NE734Jb','2fa-attempts-2fa-jQQ9HkPD14-oFUUk-ft7','0','2026-09-18 18:00:40','2026-09-18 17:51:09','2026-09-18 17:51:09'),('xpX4Hdd0CUTnewlWq5fy3SXUIBPvlAtG','2fa-attempts-2fa-nF0oDkC9tScM7s5yhDlI','0','2026-09-18 18:00:20','2026-09-18 17:50:20','2026-09-18 17:50:20');
/*!40000 ALTER TABLE `verification` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `wishlistItems`
--

DROP TABLE IF EXISTS `wishlistItems`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `wishlistItems` (
  `id` int NOT NULL AUTO_INCREMENT,
  `userId` varchar(36) NOT NULL,
  `productId` int NOT NULL,
  `createdAt` timestamp NOT NULL DEFAULT (now()),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_wishlistItems_user_product` (`userId`,`productId`),
  KEY `wishlistItems_productId_products_id_fk` (`productId`),
  KEY `idx_wishlistItems_userId` (`userId`),
  CONSTRAINT `wishlistItems_productId_products_id_fk` FOREIGN KEY (`productId`) REFERENCES `products` (`id`) ON DELETE CASCADE,
  CONSTRAINT `wishlistItems_userId_user_id_fk` FOREIGN KEY (`userId`) REFERENCES `user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=750 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `wishlistItems`
--

LOCK TABLES `wishlistItems` WRITE;
/*!40000 ALTER TABLE `wishlistItems` DISABLE KEYS */;
INSERT INTO `wishlistItems` VALUES (197,'demo-member-01',25,'2026-08-22 11:14:06'),(198,'demo-member-02',25,'2026-08-25 11:14:06'),(199,'demo-member-03',25,'2026-08-28 11:14:06'),(200,'demo-member-04',25,'2026-08-31 11:14:06'),(201,'demo-member-05',25,'2026-09-05 11:14:06'),(202,'demo-member-06',25,'2026-09-13 11:14:06'),(203,'demo-member-01',30,'2026-08-23 11:14:06'),(204,'demo-member-02',30,'2026-08-29 11:14:06'),(205,'demo-member-03',30,'2026-09-03 11:14:06'),(206,'demo-member-07',30,'2026-09-09 11:14:06'),(207,'demo-member-08',30,'2026-09-16 11:14:06'),(208,'demo-member-07',31,'2026-08-26 11:14:06'),(209,'demo-member-09',31,'2026-09-02 11:14:06'),(210,'demo-member-10',31,'2026-09-07 11:14:06'),(211,'demo-member-11',31,'2026-09-15 11:14:06'),(212,'demo-member-07',28,'2026-08-27 11:14:06'),(213,'demo-member-09',28,'2026-09-06 11:14:06'),(214,'demo-member-12',28,'2026-09-12 11:14:06'),(215,'demo-member-13',27,'2026-08-30 11:14:06'),(216,'demo-member-14',27,'2026-09-14 11:14:06'),(217,'demo-member-15',26,'2026-09-01 11:14:06'),(218,'demo-member-16',26,'2026-09-17 11:14:06'),(219,'demo-member-17',29,'2026-09-04 11:14:06'),(220,'demo-member-18',32,'2026-09-11 11:14:06'),(692,'MtTk43nCRWicn9XwqYobCc2DIU2uqbI6',25,'2026-09-18 21:38:25'),(693,'MtTk43nCRWicn9XwqYobCc2DIU2uqbI6',30,'2026-09-18 21:38:25'),(712,'UJZd1gQ2pUHHMAkoHHapNY9QW54yEile',25,'2026-09-18 21:53:27'),(713,'UJZd1gQ2pUHHMAkoHHapNY9QW54yEile',30,'2026-09-18 21:53:27'),(744,'1wKpQRdHAxKWEvupzUVg1CPWEku04eAk',25,'2026-09-19 05:45:33'),(745,'1wKpQRdHAxKWEvupzUVg1CPWEku04eAk',26,'2026-09-19 05:45:33'),(746,'1wKpQRdHAxKWEvupzUVg1CPWEku04eAk',27,'2026-09-19 05:45:33'),(747,'1wKpQRdHAxKWEvupzUVg1CPWEku04eAk',28,'2026-09-19 05:45:33'),(748,'1wKpQRdHAxKWEvupzUVg1CPWEku04eAk',29,'2026-09-19 05:45:33'),(749,'1wKpQRdHAxKWEvupzUVg1CPWEku04eAk',31,'2026-09-19 05:45:33');
/*!40000 ALTER TABLE `wishlistItems` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-09-20 14:15:31
