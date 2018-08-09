-- phpMyAdmin SQL Dump
-- version 4.7.4
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Erstellungszeit: 09. Aug 2018 um 13:26
-- Server-Version: 10.2.16-MariaDB-10.2.16+maria~jessie-log
-- PHP-Version: 5.6.37-1+0~20180725093903.2+jessie~1.gbp606419

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Datenbank: `samporg`
--

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `AdminLog`
--

CREATE TABLE `AdminLog` (
  `id` int(255) NOT NULL,
  `Command` varchar(255) NOT NULL,
  `Admin` varchar(255) NOT NULL,
  `Target` varchar(255) NOT NULL,
  `Time` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `Player`
--

CREATE TABLE `Player` (
  `id` int(11) NOT NULL,
  `Name` varchar(255) NOT NULL,
  `Password` varchar(255) NOT NULL,
  `Salt` varchar(255) NOT NULL,
  `Adminlevel` int(255) NOT NULL,
  `Money` int(255) NOT NULL,
  `Banned` int(255) NOT NULL,
  `BanReason` varchar(255) NOT NULL,
  `BanDate` varchar(255) NOT NULL,
  `BannedBy` varchar(255) NOT NULL,
  `posX` float(255,5) NOT NULL,
  `posY` float(255,5) NOT NULL,
  `posZ` float(255,5) NOT NULL,
  `posA` float(255,5) NOT NULL,
  `fsID` int(255) NOT NULL,
  `Skin` int(255) NOT NULL,
  `FightStyle` int(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `PunishLog`
--

CREATE TABLE `PunishLog` (
  `id` int(255) NOT NULL,
  `Type` varchar(255) NOT NULL,
  `Target` varchar(255) NOT NULL,
  `Admin` varchar(255) NOT NULL,
  `Reason` varchar(255) NOT NULL,
  `Time` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `Vehicles`
--

CREATE TABLE `Vehicles` (
  `id` int(11) NOT NULL,
  `model` int(11) NOT NULL DEFAULT 0,
  `licenseplate` varchar(12) NOT NULL DEFAULT '',
  `kilometers` int(11) NOT NULL DEFAULT 0,
  `owner` int(11) NOT NULL DEFAULT 0,
  `tank` int(11) NOT NULL DEFAULT 0,
  `color1` int(11) NOT NULL DEFAULT 0,
  `color2` int(11) NOT NULL DEFAULT 0,
  `paintjob` int(11) NOT NULL DEFAULT 1337,
  `spoiler` int(11) NOT NULL DEFAULT 0,
  `hood` int(11) NOT NULL DEFAULT 0,
  `roof` int(11) NOT NULL DEFAULT 0,
  `sideskirt_left` int(11) NOT NULL DEFAULT 0,
  `sideskirt_right` int(11) NOT NULL DEFAULT 0,
  `nitro` int(11) NOT NULL DEFAULT 0,
  `lamps` int(11) NOT NULL DEFAULT 0,
  `exhaust` int(11) NOT NULL DEFAULT 0,
  `wheels` int(11) NOT NULL DEFAULT 0,
  `stereo` int(11) NOT NULL DEFAULT 0,
  `hydraulics` int(11) NOT NULL DEFAULT 0,
  `bullbar` int(11) NOT NULL DEFAULT 0,
  `bullbar_rear` int(11) NOT NULL DEFAULT 0,
  `bullbar_front` int(11) NOT NULL DEFAULT 0,
  `sign_front` int(11) NOT NULL DEFAULT 0,
  `bumper_front` int(11) NOT NULL DEFAULT 0,
  `bumper_rear` int(11) NOT NULL DEFAULT 0,
  `bullbars` int(11) NOT NULL DEFAULT 0,
  `vents` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Indizes der exportierten Tabellen
--

--
-- Indizes für die Tabelle `AdminLog`
--
ALTER TABLE `AdminLog`
  ADD PRIMARY KEY (`id`);

--
-- Indizes für die Tabelle `Player`
--
ALTER TABLE `Player`
  ADD PRIMARY KEY (`id`);

--
-- Indizes für die Tabelle `PunishLog`
--
ALTER TABLE `PunishLog`
  ADD PRIMARY KEY (`id`);

--
-- Indizes für die Tabelle `Vehicles`
--
ALTER TABLE `Vehicles`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT für exportierte Tabellen
--

--
-- AUTO_INCREMENT für Tabelle `AdminLog`
--
ALTER TABLE `AdminLog`
  MODIFY `id` int(255) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT für Tabelle `Player`
--
ALTER TABLE `Player`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT für Tabelle `PunishLog`
--
ALTER TABLE `PunishLog`
  MODIFY `id` int(255) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT für Tabelle `Vehicles`
--
ALTER TABLE `Vehicles`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
