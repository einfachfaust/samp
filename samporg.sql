/*
Navicat MySQL Data Transfer

Source Server         : Local
Source Server Version : 50505
Source Host           : localhost:3306
Source Database       : samporg

Target Server Type    : MYSQL
Target Server Version : 50505
File Encoding         : 65001

Date: 2018-08-05 22:28:43
*/

SET FOREIGN_KEY_CHECKS=0;

-- ----------------------------
-- Table structure for `adminlog`
-- ----------------------------
DROP TABLE IF EXISTS `adminlog`;
CREATE TABLE `adminlog` (
  `id` int(255) NOT NULL AUTO_INCREMENT,
  `Command` varchar(255) NOT NULL,
  `Admin` varchar(255) NOT NULL,
  `Target` varchar(255) NOT NULL,
  `Time` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- ----------------------------
-- Records of adminlog
-- ----------------------------

-- ----------------------------
-- Table structure for `player`
-- ----------------------------
DROP TABLE IF EXISTS `player`;
CREATE TABLE `player` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Name` varchar(255) NOT NULL,
  `Password` varchar(255) NOT NULL,
  `Salt` varchar(255) NOT NULL,
  `Adminlevel` int(255) NOT NULL,
  `Banned` int(255) NOT NULL,
  `BanReason` varchar(255) NOT NULL,
  `BanDate` varchar(255) NOT NULL,
  `BannedBy` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;

-- ----------------------------
-- Records of player
-- ----------------------------

-- ----------------------------
-- Table structure for `punishlog`
-- ----------------------------
DROP TABLE IF EXISTS `punishlog`;
CREATE TABLE `punishlog` (
  `id` int(255) NOT NULL AUTO_INCREMENT,
  `Type` varchar(255) NOT NULL,
  `Target` varchar(255) NOT NULL,
  `Admin` varchar(255) NOT NULL,
  `Reason` varchar(255) NOT NULL,
  `Time` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- ----------------------------
-- Records of punishlog
-- ----------------------------

-- ----------------------------
-- Table structure for `vehicles`
-- ----------------------------
DROP TABLE IF EXISTS `vehicles`;
CREATE TABLE `vehicles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `model` int(11) NOT NULL DEFAULT '0',
  `licenseplate` varchar(12) NOT NULL DEFAULT '',
  `kilometers` int(11) NOT NULL DEFAULT '0',
  `owner` int(11) NOT NULL DEFAULT '0',
  `tank` int(11) NOT NULL DEFAULT '0',
  `color1` int(11) NOT NULL DEFAULT '0',
  `color2` int(11) NOT NULL DEFAULT '0',
  `paintjob` int(11) NOT NULL DEFAULT '1337',
  `spoiler` int(11) NOT NULL DEFAULT '0',
  `hood` int(11) NOT NULL DEFAULT '0',
  `roof` int(11) NOT NULL DEFAULT '0',
  `sideskirt_left` int(11) NOT NULL DEFAULT '0',
  `sideskirt_right` int(11) NOT NULL DEFAULT '0',
  `nitro` int(11) NOT NULL DEFAULT '0',
  `lamps` int(11) NOT NULL DEFAULT '0',
  `exhaust` int(11) NOT NULL DEFAULT '0',
  `wheels` int(11) NOT NULL DEFAULT '0',
  `stereo` int(11) NOT NULL DEFAULT '0',
  `hydraulics` int(11) NOT NULL DEFAULT '0',
  `bullbar` int(11) NOT NULL DEFAULT '0',
  `bullbar_rear` int(11) NOT NULL DEFAULT '0',
  `bullbar_front` int(11) NOT NULL DEFAULT '0',
  `sign_front` int(11) NOT NULL DEFAULT '0',
  `bumper_front` int(11) NOT NULL DEFAULT '0',
  `bumper_rear` int(11) NOT NULL DEFAULT '0',
  `bullbars` int(11) NOT NULL DEFAULT '0',
  `vents` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1;

-- ----------------------------
-- Records of vehicles
-- ----------------------------