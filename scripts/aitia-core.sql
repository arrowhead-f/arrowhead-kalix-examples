DROP DATABASE IF EXISTS `arrowhead`;
CREATE DATABASE `arrowhead`;
USE `arrowhead`;

-- create tables
CREATE DATABASE IF NOT EXISTS `arrowhead`;
USE `arrowhead`;

-- Common

CREATE TABLE IF NOT EXISTS `cloud` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `operator` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `secure` int(1) NOT NULL DEFAULT 0 COMMENT 'Is secure?',
  `neighbor` int(1) NOT NULL DEFAULT 0 COMMENT 'Is neighbor cloud?',
  `own_cloud` int(1) NOT NULL DEFAULT 0 COMMENT 'Is own cloud?',
  `authentication_info` varchar(2047) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `cloud` (`operator`,`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `relay` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `address` varchar(255) NOT NULL,
  `port` int(11) NOT NULL,
  `secure` int(1) NOT NULL DEFAULT 0,
  `exclusive` int(1) NOT NULL DEFAULT 0,
  `type` varchar(255) NOT NULL DEFAULT 'GENERAL_RELAY',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `pair` (`address`, `port`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `cloud_gatekeeper_relay` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `cloud_id` bigint(20) NOT NULL,
  `relay_id` bigint(20) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `pair` (`cloud_id`,`relay_id`),
  CONSTRAINT `gk_cloud_constr` FOREIGN KEY (`cloud_id`) REFERENCES `cloud` (`id`) ON DELETE CASCADE,
  CONSTRAINT `gk_relay_constr` FOREIGN KEY (`relay_id`) REFERENCES `relay` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `cloud_gateway_relay` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `cloud_id` bigint(20) NOT NULL,
  `relay_id` bigint(20) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `pair` (`cloud_id`,`relay_id`),
  CONSTRAINT `gw_cloud_constr` FOREIGN KEY (`cloud_id`) REFERENCES `cloud` (`id`) ON DELETE CASCADE,
  CONSTRAINT `gw_relay_constr` FOREIGN KEY (`relay_id`) REFERENCES `relay` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `system_` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `system_name` varchar(255) NOT NULL,
  `address` varchar(255) NOT NULL,
  `port` int(11) NOT NULL,
  `authentication_info` varchar(2047) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `triple` (`system_name`,`address`,`port`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `device` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `device_name` varchar(255) NOT NULL,
  `address` varchar(255) NOT NULL,
  `mac_address` varchar(255) NOT NULL,
  `authentication_info` varchar(2047) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `double` (`device_name`,`mac_address`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `service_definition` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `service_definition` varchar(255) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `service_definition` (`service_definition`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `service_interface` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `interface_name` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `interface` (`interface_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT IGNORE INTO `service_interface` (interface_name) VALUES ('HTTP-SECURE-JSON');
INSERT IGNORE INTO `service_interface` (interface_name) VALUES ('HTTP-INSECURE-JSON');

-- Device Registry

CREATE TABLE IF NOT EXISTS `device_registry` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `device_id` bigint(20) NOT NULL,
  `end_of_validity` timestamp NULL DEFAULT NULL,
  `metadata` text,
  `version` int(11) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `device_registry_device` (`device_id`),
  CONSTRAINT `device_registry_device` FOREIGN KEY (`device_id`) REFERENCES `device` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- System Registry

CREATE TABLE IF NOT EXISTS `system_registry` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `system_id` bigint(20) NOT NULL,
  `device_id` bigint(20) NOT NULL,
  `end_of_validity` timestamp NULL DEFAULT NULL,
  `metadata` text,
  `version` int(11) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `system_registry_pair` (`system_id`,`device_id`),
  KEY `system_registry_device` (`device_id`),
  CONSTRAINT `system_registry_system` FOREIGN KEY (`system_id`) REFERENCES `system_` (`id`) ON DELETE CASCADE,
  CONSTRAINT `system_registry_device` FOREIGN KEY (`device_id`) REFERENCES `device` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Service Registry

CREATE TABLE IF NOT EXISTS `service_registry` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `service_id` bigint(20) NOT NULL,
  `system_id` bigint(20) NOT NULL,
  `service_uri` varchar(255) DEFAULT NULL,
  `end_of_validity` timestamp NULL DEFAULT NULL,
  `secure` varchar(255) NOT NULL DEFAULT 'NOT_SECURE',
  `metadata` text,
  `version` int(11) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `service_registry_pair` (`service_id`,`system_id`),
  KEY `service_registry_system` (`system_id`),
  CONSTRAINT `service_registry_service` FOREIGN KEY (`service_id`) REFERENCES `service_definition` (`id`) ON DELETE CASCADE,
  CONSTRAINT `service_registry_system` FOREIGN KEY (`system_id`) REFERENCES `system_` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `service_registry_interface_connection` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `service_registry_id` bigint(20) NOT NULL,
  `interface_id` bigint(20) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `pair` (`service_registry_id`,`interface_id`),
  KEY `interface_sr` (`interface_id`),
  CONSTRAINT `interface_sr` FOREIGN KEY (`interface_id`) REFERENCES `service_interface` (`id`) ON DELETE CASCADE,
  CONSTRAINT `service_registry` FOREIGN KEY (`service_registry_id`) REFERENCES `service_registry` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Authorization

CREATE TABLE IF NOT EXISTS `authorization_intra_cloud` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `consumer_system_id` bigint(20) NOT NULL,
  `provider_system_id` bigint(20) NOT NULL,
  `service_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `rule` (`consumer_system_id`,`provider_system_id`,`service_id`),
  KEY `provider` (`provider_system_id`),
  KEY `service_intra_auth` (`service_id`),
  CONSTRAINT `service_intra_auth` FOREIGN KEY (`service_id`) REFERENCES `service_definition` (`id`) ON DELETE CASCADE,
  CONSTRAINT `provider` FOREIGN KEY (`provider_system_id`) REFERENCES `system_` (`id`) ON DELETE CASCADE,
  CONSTRAINT `consumer` FOREIGN KEY (`consumer_system_id`) REFERENCES `system_` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `authorization_inter_cloud` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `consumer_cloud_id` bigint(20) NOT NULL,
  `provider_system_id` bigint(20) NOT NULL,
  `service_id` bigint(20) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `rule` (`consumer_cloud_id`, `provider_system_id`, `service_id`),
  KEY `service_inter_auth` (`service_id`),
  CONSTRAINT `cloud` FOREIGN KEY (`consumer_cloud_id`) REFERENCES `cloud` (`id`) ON DELETE CASCADE,
  CONSTRAINT `service_inter_auth` FOREIGN KEY (`service_id`) REFERENCES `service_definition` (`id`) ON DELETE CASCADE,
  CONSTRAINT `provider_inter_auth` FOREIGN KEY (`provider_system_id`) REFERENCES `system_` (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `authorization_inter_cloud_interface_connection` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `authorization_inter_cloud_id` bigint(20) NOT NULL,
  `interface_id` bigint(20) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `pair` (`authorization_inter_cloud_id`,`interface_id`),
  KEY `interface_inter` (`interface_id`),
  CONSTRAINT `auth_inter_interface` FOREIGN KEY (`interface_id`) REFERENCES `service_interface` (`id`) ON DELETE CASCADE,
  CONSTRAINT `auth_inter_cloud` FOREIGN KEY (`authorization_inter_cloud_id`) REFERENCES `authorization_inter_cloud` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `authorization_intra_cloud_interface_connection` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `authorization_intra_cloud_id` bigint(20) NOT NULL,
  `interface_id` bigint(20) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `pair` (`authorization_intra_cloud_id`,`interface_id`),
  KEY `interface_intra` (`interface_id`),
  CONSTRAINT `auth_intra_interface` FOREIGN KEY (`interface_id`) REFERENCES `service_interface` (`id`) ON DELETE CASCADE,
  CONSTRAINT `auth_intra_cloud` FOREIGN KEY (`authorization_intra_cloud_id`) REFERENCES `authorization_intra_cloud` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Orchestrator

CREATE TABLE IF NOT EXISTS `orchestrator_store` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `consumer_system_id` bigint(20) NOT NULL,
  `provider_system_id` bigint(20) NOT NULL,
  `foreign_` int(1) NOT NULL DEFAULT 0,
  `service_id` bigint(20) NOT NULL,
  `service_interface_id` bigint(20) NOT NULL,
  `priority` int(11) NOT NULL,
  `attribute` text,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `priority_rule` (`service_id`, `service_interface_id`, `consumer_system_id`,`priority`),
  UNIQUE KEY `duplication_rule` (`service_id`, `service_interface_id`, `consumer_system_id`,`provider_system_id`, `foreign_`),
  CONSTRAINT `consumer_orch` FOREIGN KEY (`consumer_system_id`) REFERENCES `system_` (`id`) ON DELETE CASCADE,
  CONSTRAINT `service_orch` FOREIGN KEY (`service_id`) REFERENCES `service_definition` (`id`) ON DELETE CASCADE,
  CONSTRAINT `service_intf_orch` FOREIGN KEY (`service_interface_id`) REFERENCES `service_interface` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `foreign_system` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `provider_cloud_id` bigint(20) NOT NULL,
  `system_name` varchar(255) NOT NULL,
  `address` varchar(255) NOT NULL,
  `port` int(11) NOT NULL,
  `authentication_info` varchar(2047) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `triple` (`system_name`,`address`,`port`),
  CONSTRAINT `foreign_cloud` FOREIGN KEY (`provider_cloud_id`) REFERENCES `cloud` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Logs

CREATE TABLE IF NOT EXISTS `logs` (
  `log_id` varchar(100) NOT NULL,
  `entry_date` timestamp NULL DEFAULT NULL,
  `logger` varchar(100) DEFAULT NULL,
  `log_level` varchar(100) DEFAULT NULL,
  `message` text,
  `exception` text,
  PRIMARY KEY (`log_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Event Handler

CREATE TABLE IF NOT EXISTS `event_type` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `event_type_name` varchar(255) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `eventtype` (`event_type_name`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `subscription` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `system_id` bigint(20) NOT NULL,
  `event_type_id` bigint(20) NOT NULL,
  `filter_meta_data` text,
  `match_meta_data` int(1) NOT NULL DEFAULT 0,
  `only_predefined_publishers` int(1) NOT NULL DEFAULT 0,
  `notify_uri` text NOT NULL,
  `start_date` timestamp NULL DEFAULT NULL,
  `end_date` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `pair` (`event_type_id`,`system_id`),
  CONSTRAINT `subscriber_system` FOREIGN KEY (`system_id`) REFERENCES `system_` (`id`) ON DELETE CASCADE,
  CONSTRAINT `event_type` FOREIGN KEY (`event_type_id`) REFERENCES `event_type` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `subscription_publisher_connection` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `subscription_id` bigint(20) NOT NULL,
  `system_id` bigint(20) NOT NULL,
  `authorized` int(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `pair` (`subscription_id`,`system_id`),
  CONSTRAINT `subscription_constraint` FOREIGN KEY (`subscription_id`) REFERENCES `subscription` (`id`) ON DELETE CASCADE,
  CONSTRAINT `system_constraint` FOREIGN KEY (`system_id`) REFERENCES `system_` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- DataManager

CREATE TABLE IF NOT EXISTS `dmhist_services` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `system_name` varchar(255) NOT NULL,
  `service_name` varchar(255) NOT NULL,
  `service_type` varchar(255),
  last_update timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `dmhist_messages` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `sid` bigint(20) NOT NULL,
  `bt` double NOT NULL,
  `mint` double NOT NULL,
  `maxt` double NOT NULL,
  `msg` BLOB NOT NULL,
  `datastored` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  CONSTRAINT `service_id_constr` FOREIGN KEY (`sid`) REFERENCES `dmhist_services` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `dmhist_entries` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `sid` bigint(20) NOT NULL,
  `mid` bigint(20) NOT NULL,
  `n` varchar(128) NOT NULL,
  `t` double NOT NULL,
  `u` varchar(64),
  `v`  double,
  `vs` BLOB,
  `vb` BOOLEAN,
  PRIMARY KEY (`id`),
  CONSTRAINT `service_id_fk` FOREIGN KEY(`sid`) REFERENCES `dmhist_services`(`id`) ON DELETE CASCADE,
  CONSTRAINT `message_id_fk` FOREIGN KEY(`mid`) REFERENCES `dmhist_messages`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Choreographer

CREATE TABLE IF NOT EXISTS `choreographer_plan` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `first_action_id` bigint(20),
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `choreographer_action` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `plan_id` bigint(20) NOT NULL,
  `next_action_id` bigint(20) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name_plan_id_unique_key` (`name`,`plan_id`),
  CONSTRAINT `next_action` FOREIGN KEY (`next_action_id`) REFERENCES `choreographer_action` (`id`) ON DELETE CASCADE,
  CONSTRAINT `plan` FOREIGN KEY (`plan_id`) REFERENCES `choreographer_plan` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

ALTER TABLE `choreographer_plan` ADD FOREIGN KEY (`first_action_id`) references `choreographer_action`(`id`);

CREATE TABLE IF NOT EXISTS `choreographer_step` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `action_first_step_id` bigint(20),
  `action_id` bigint(20) NOT NULL,
  `service_name` varchar(255) NOT NULL,
  `metadata` text,
  `parameters` text,
  `quantity` int(20) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name_action_id_unique_key` (`name`, `action_id`),
  CONSTRAINT `action_first_step` FOREIGN KEY (`action_first_step_id`) REFERENCES `choreographer_action` (`id`) ON DELETE CASCADE,
  CONSTRAINT `action` FOREIGN KEY (`action_id`) REFERENCES `choreographer_action` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `choreographer_step_next_step_connection` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `step_id` bigint(20) NOT NULL,
  `next_step_id` bigint(20) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  CONSTRAINT `current_step` FOREIGN KEY (`step_id`) REFERENCES choreographer_step (`id`) ON DELETE CASCADE,
  CONSTRAINT `next_step` FOREIGN KEY (`step_id`) REFERENCES choreographer_step (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `choreographer_session` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `plan_id` bigint(20) NOT NULL,
  `started_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `status` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `session_plan` FOREIGN KEY (`plan_id`) REFERENCES `choreographer_plan` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `choreographer_running_step` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `step_id` bigint(20) NOT NULL,
  `session_id` bigint(20) NOT NULL,
  `status` varchar(255) NOT NULL,
  `message` text,
  `started_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  CONSTRAINT `running_step` FOREIGN KEY (`step_id`) REFERENCES `choreographer_step` (`id`),
  CONSTRAINT `running_step_session` FOREIGN KEY (`session_id`) REFERENCES `choreographer_session`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `choreographer_worklog` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `entry_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `message` text,
  `exception` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- QoS Monitor
-- Intra

CREATE TABLE IF NOT EXISTS `qos_intra_measurement` (
	`id` bigint(20) PRIMARY KEY AUTO_INCREMENT,
	`system_id` bigint(20) NOT NULL,
	`measurement_type` varchar(255) NOT NULL,
	`last_measurement_at` timestamp NOT NULL,
	`created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
	`updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	CONSTRAINT `fk_system` FOREIGN KEY (`system_id`) REFERENCES `system_` (`id`) ON DELETE CASCADE,
	UNIQUE KEY `unique_system_id_measurement_type` (`system_id`, `measurement_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `qos_intra_ping_measurement` (
	`id` bigint(20) PRIMARY KEY AUTO_INCREMENT,
	`measurement_id` bigint(20) NOT NULL,
	`available` int(1) NOT NULL DEFAULT 0,
	`last_access_at` timestamp NULL DEFAULT NULL,
	`min_response_time` int(11) DEFAULT NULL,
	`max_response_time` int(11) DEFAULT NULL,
	`mean_response_time_with_timeout` int(11) NULL DEFAULT NULL,
	`mean_response_time_without_timeout` int(11) NULL DEFAULT NULL,
	`jitter_with_timeout` int(11) NULL DEFAULT NULL,
	`jitter_without_timeout` int(11) NULL DEFAULT NULL,
	`lost_per_measurement_percent` int(3) NOT NULL DEFAULT 0,
	`sent` bigint(20) NOT NULL DEFAULT 0,
	`received` bigint(20) NOT NULL DEFAULT 0,
	`count_started_at` timestamp NULL,
	`sent_all` bigint(20) NOT NULL DEFAULT 0,
	`received_all` bigint(20) NOT NULL DEFAULT 0,
	`created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
	`updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	CONSTRAINT `fk_intra_measurement` FOREIGN KEY (`measurement_id`) REFERENCES `qos_intra_measurement` (`id`) ON DELETE CASCADE,
	UNIQUE KEY `unique_intra_measurement` (`measurement_id`)
	
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `qos_intra_ping_measurement_log` (
	`id` bigint(20) PRIMARY KEY AUTO_INCREMENT,
	`measured_system_address` varchar(255) NOT NULL,
	`available` int(1) NOT NULL DEFAULT 0,
	`min_response_time` int(11) DEFAULT NULL,
	`max_response_time` int(11) DEFAULT NULL,
	`mean_response_time_with_timeout` int(11) NULL DEFAULT NULL,
	`mean_response_time_without_timeout` int(11) NULL DEFAULT NULL,
	`jitter_with_timeout` int(11) NULL DEFAULT NULL,
	`jitter_without_timeout` int(11) NULL DEFAULT NULL,
	`lost_per_measurement_percent` int(3) NOT NULL DEFAULT 0,
	`sent` bigint(20) NOT NULL DEFAULT 0,
	`received` bigint(20) NOT NULL DEFAULT 0,
	`measured_at` timestamp NOT NULL,
	`created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
	`updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
	
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `qos_intra_ping_measurement_log_details` (
	`id` bigint(20) PRIMARY KEY AUTO_INCREMENT,
	`measurement_log_id` bigint(20) NOT NULL,
	`measurement_sequenece_number` int(3) NOT NULL,
	`success_flag` int(1) NOT NULL DEFAULT 0,
	`timeout_flag` int(1) NOT NULL DEFAULT 0,
	`error_message` varchar(255) NULL DEFAULT NULL,
	`throwable` varchar(255) NULL DEFAULT NULL,
	`size_` int(11) NULL DEFAULT NULL,
	`rtt` int(11) NULL DEFAULT NULL,
	`ttl` int(3) NULL DEFAULT NULL,
	`duration` int(5) NULL DEFAULT NULL,
	`measured_at` timestamp NOT NULL,
	`created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
	`updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	CONSTRAINT `fk_intra_measurement_log` FOREIGN KEY (`measurement_log_id`) REFERENCES `qos_intra_ping_measurement_log` (`id`) ON DELETE CASCADE
	
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- QoS Monitor
-- Inter

CREATE TABLE IF NOT EXISTS `qos_inter_direct_measurement` (
	`id` bigint(20) PRIMARY KEY AUTO_INCREMENT,
	`cloud_id` bigint(20) NOT NULL,
	`address` varchar(255) NOT NULL,
	`measurement_type` varchar(255) NOT NULL,
	`last_measurement_at` timestamp NOT NULL,
	`created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
	`updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	CONSTRAINT `fk_cloud_inter_direct` FOREIGN KEY (`cloud_id`) REFERENCES `cloud` (`id`) ON DELETE CASCADE,
	UNIQUE KEY `unique_cloud_id_address_measurement_type` (`cloud_id`, `address`, `measurement_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `qos_inter_direct_ping_measurement` (
	`id` bigint(20) PRIMARY KEY AUTO_INCREMENT,
	`measurement_id` bigint(20) NOT NULL,
	`available` int(1) NOT NULL DEFAULT 0,
	`last_access_at` timestamp NULL DEFAULT NULL,
	`min_response_time` int(11) DEFAULT NULL,
	`max_response_time` int(11) DEFAULT NULL,
	`mean_response_time_with_timeout` int(11) NULL DEFAULT NULL,
	`mean_response_time_without_timeout` int(11) NULL DEFAULT NULL,
	`jitter_with_timeout` int(11) NULL DEFAULT NULL,
	`jitter_without_timeout` int(11) NULL DEFAULT NULL,
	`lost_per_measurement_percent` int(3) NOT NULL DEFAULT 0,
	`sent` bigint(20) NOT NULL DEFAULT 0,
	`received` bigint(20) NOT NULL DEFAULT 0,
	`count_started_at` timestamp NULL,
	`sent_all` bigint(20) NOT NULL DEFAULT 0,
	`received_all` bigint(20) NOT NULL DEFAULT 0,
	`created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
	`updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	CONSTRAINT `fk_inter_direct_measurement` FOREIGN KEY (`measurement_id`) REFERENCES `qos_inter_direct_measurement` (`id`) ON DELETE CASCADE,
	UNIQUE KEY `unique_measurement` (`measurement_id`)
	
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `qos_inter_direct_ping_measurement_log` (
	`id` bigint(20) PRIMARY KEY AUTO_INCREMENT,
	`measured_system_address` varchar(255) NOT NULL,
	`available` int(1) NOT NULL DEFAULT 0,
	`min_response_time` int(11) DEFAULT NULL,
	`max_response_time` int(11) DEFAULT NULL,
	`mean_response_time_with_timeout` int(11) NULL DEFAULT NULL,
	`mean_response_time_without_timeout` int(11) NULL DEFAULT NULL,
	`jitter_with_timeout` int(11) NULL DEFAULT NULL,
	`jitter_without_timeout` int(11) NULL DEFAULT NULL,
	`lost_per_measurement_percent` int(3) NOT NULL DEFAULT 0,
	`sent` bigint(20) NOT NULL DEFAULT 0,
	`received` bigint(20) NOT NULL DEFAULT 0,
	`measured_at` timestamp NOT NULL,
	`created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
	`updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
	
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `qos_inter_direct_ping_measurement_log_details` (
	`id` bigint(20) PRIMARY KEY AUTO_INCREMENT,
	`measurement_log_id` bigint(20) NOT NULL,
	`measurement_sequenece_number` int(3) NOT NULL,
	`success_flag` int(1) NOT NULL DEFAULT 0,
	`timeout_flag` int(1) NOT NULL DEFAULT 0,
	`error_message` varchar(255) NULL DEFAULT NULL,
	`throwable` varchar(255) NULL DEFAULT NULL,
	`size_` int(11) NULL DEFAULT NULL,
	`rtt` int(11) NULL DEFAULT NULL,
	`ttl` int(3) NULL DEFAULT NULL,
	`duration` int(5) NULL DEFAULT NULL,
	`measured_at` timestamp NOT NULL,
	`created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
	`updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	CONSTRAINT `fk_inter_direct_ping_measurement_log` FOREIGN KEY (`measurement_log_id`) REFERENCES `qos_inter_direct_ping_measurement_log` (`id`) ON DELETE CASCADE
	
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `qos_inter_relay_measurement` (
	`id` bigint(20) PRIMARY KEY AUTO_INCREMENT,
	`cloud_id` bigint(20) NOT NULL,
	`relay_id` bigint(20) NOT NULL,
	`measurement_type` varchar(255) NOT NULL,
	`status` varchar(255) NOT NULL,
	`last_measurement_at` timestamp NOT NULL,
	`created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
	`updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	CONSTRAINT `fk_cloud_inter_relay` FOREIGN KEY (`cloud_id`) REFERENCES `cloud` (`id`) ON DELETE CASCADE,
	CONSTRAINT `fk_relay_inter_relay` FOREIGN KEY (`relay_id`) REFERENCES `relay` (`id`) ON DELETE CASCADE,
	UNIQUE KEY `unique_cloud_relay_measurement_type` (`cloud_id`, `relay_id`, `measurement_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `qos_inter_relay_echo_measurement` (
	`id` bigint(20) PRIMARY KEY AUTO_INCREMENT,
	`measurement_id` bigint(20) NOT NULL,
	`last_access_at` timestamp NULL DEFAULT NULL,
	`min_response_time` int(11) DEFAULT NULL,
	`max_response_time` int(11) DEFAULT NULL,
	`mean_response_time_with_timeout` int(11) NULL DEFAULT NULL,
	`mean_response_time_without_timeout` int(11) NULL DEFAULT NULL,
	`jitter_with_timeout` int(11) NULL DEFAULT NULL,
	`jitter_without_timeout` int(11) NULL DEFAULT NULL,
	`lost_per_measurement_percent` int(3) NOT NULL DEFAULT 0,
	`sent` bigint(20) NOT NULL DEFAULT 0,
	`received` bigint(20) NOT NULL DEFAULT 0,
	`count_started_at` timestamp NULL,
	`sent_all` bigint(20) NOT NULL DEFAULT 0,
	`received_all` bigint(20) NOT NULL DEFAULT 0,
	`created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
	`updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	CONSTRAINT `fk_inter_relay_measurement` FOREIGN KEY (`measurement_id`) REFERENCES `qos_inter_relay_measurement` (`id`) ON DELETE CASCADE,
	UNIQUE KEY `unique_inter_relay_echo_measurement` (`measurement_id`)
	
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `qos_inter_relay_echo_measurement_log` (
	`id` bigint(20) PRIMARY KEY AUTO_INCREMENT,
	`measurement_id` bigint(20) NOT NULL,
	`measurement_sequenece_number` int(3) NOT NULL,
	`timeout_flag` int(1) NOT NULL DEFAULT 0,
	`error_message` varchar(255) NULL DEFAULT NULL,
	`throwable` varchar(255) NULL DEFAULT NULL,
	`size_` int(11) NULL DEFAULT NULL,
	`duration` int(5) NULL DEFAULT NULL,
	`measured_at` timestamp NOT NULL,
	`created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
	`updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	CONSTRAINT `fk_inter_relay_echo_measurement_log` FOREIGN KEY (`measurement_id`) REFERENCES `qos_inter_relay_measurement` (`id`) ON DELETE CASCADE
	
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- QoS Manager

CREATE TABLE IF NOT EXISTS `qos_reservation` (
	`id` bigint(20) PRIMARY KEY AUTO_INCREMENT,
	`reserved_provider_id` bigint(20) NOT NULL,
	`reserved_service_id` bigint(20) NOT NULL,
	`consumer_system_name` varchar(255) NOT NULL,
	`consumer_address` varchar(255) NOT NULL,
	`consumer_port` int(11) NOT NULL,
	`reserved_to` timestamp NOT NULL,
	`temporary_lock` int(1) NOT NULL DEFAULT 0,
	`created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
	`updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	CONSTRAINT `fk_reserved_provider` FOREIGN KEY (`reserved_provider_id`) REFERENCES `system_` (`id`) ON DELETE CASCADE,
	CONSTRAINT `fk_reserved_service` FOREIGN KEY (`reserved_service_id`) REFERENCES `service_definition` (`id`) ON DELETE CASCADE,
	UNIQUE KEY `unique_reserved_provider_and_service` (`reserved_provider_id`, `reserved_service_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Certificate Authority

CREATE TABLE IF NOT EXISTS `ca_certificate` (
  `id` bigint(20) PRIMARY KEY AUTO_INCREMENT,
  `common_name` varchar(255) NOT NULL,
  `serial` bigint(20) NOT NULL,
  `created_by` varchar(255) NOT NULL,
  `valid_after` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `valid_before` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `revoked_at` timestamp NULL,
  UNIQUE KEY `unique_certificate_serial` (`serial`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8;

CREATE TABLE IF NOT EXISTS `ca_trusted_key` (
  `id` bigint(20) PRIMARY KEY AUTO_INCREMENT,
  `public_key` text NOT NULL,
  `hash` varchar(255) NOT NULL,
  `description` varchar(255) NOT NULL,
  `valid_after` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `valid_before` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY `unique_hash` (`hash`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8;

-- Set up privileges

-- Service Registry
CREATE USER IF NOT EXISTS 'service_registry'@'localhost' IDENTIFIED BY 'ZzNNpxrbZGVvfJ8';
CREATE USER IF NOT EXISTS 'service_registry'@'%' IDENTIFIED BY 'ZzNNpxrbZGVvfJ8';
REVOKE ALL, GRANT OPTION FROM 'service_registry'@'localhost';

GRANT ALL PRIVILEGES ON `arrowhead`.`system_` TO 'service_registry'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`service_definition` TO 'service_registry'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`service_interface` TO 'service_registry'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`service_registry` TO 'service_registry'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`service_registry_interface_connection` TO 'service_registry'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`cloud` TO 'service_registry'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`relay` TO 'service_registry'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`cloud_gatekeeper_relay` TO 'service_registry'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`cloud_gateway_relay` TO 'service_registry'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`authorization_intra_cloud` TO 'service_registry'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`authorization_intra_cloud_interface_connection` TO 'service_registry'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`authorization_inter_cloud` TO 'service_registry'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`authorization_inter_cloud_interface_connection` TO 'service_registry'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`orchestrator_store` TO 'service_registry'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`subscription` TO 'service_registry'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`subscription_publisher_connection` TO 'service_registry'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`choreographer_action_plan` TO 'service_registry'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`choreographer_action` TO 'service_registry'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`choreographer_action_step` TO 'service_registry'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`choreographer_action_plan_action_connection` TO 'service_registry'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`choreographer_action_action_step_connection` TO 'service_registry'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`choreographer_action_step_service_definition_connection` TO 'service_registry'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`choreographer_next_action_step` TO 'service_registry'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`logs` TO 'service_registry'@'localhost';

REVOKE ALL, GRANT OPTION FROM 'service_registry'@'%';

GRANT ALL PRIVILEGES ON `arrowhead`.`system_` TO 'service_registry'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`service_definition` TO 'service_registry'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`service_interface` TO 'service_registry'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`service_registry` TO 'service_registry'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`service_registry_interface_connection` TO 'service_registry'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`cloud` TO 'service_registry'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`relay` TO 'service_registry'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`cloud_gatekeeper_relay` TO 'service_registry'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`cloud_gateway_relay` TO 'service_registry'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`authorization_intra_cloud` TO 'service_registry'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`authorization_intra_cloud_interface_connection` TO 'service_registry'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`authorization_inter_cloud` TO 'service_registry'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`authorization_inter_cloud_interface_connection` TO 'service_registry'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`orchestrator_store` TO 'service_registry'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`subscription` TO 'service_registry'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`subscription_publisher_connection` TO 'service_registry'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`choreographer_action_plan` TO 'service_registry'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`choreographer_action` TO 'service_registry'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`choreographer_action_step` TO 'service_registry'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`choreographer_action_plan_action_connection` TO 'service_registry'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`choreographer_action_action_step_connection` TO 'service_registry'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`choreographer_action_step_service_definition_connection` TO 'service_registry'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`choreographer_next_action_step` TO 'service_registry'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`logs` TO 'service_registry'@'%';

FLUSH PRIVILEGES;

-- System Registry
CREATE USER IF NOT EXISTS 'system_registry'@'localhost' IDENTIFIED BY 'Kh12Hhgaxzo7haf';
CREATE USER IF NOT EXISTS 'system_registry'@'%' IDENTIFIED BY 'Kh12Hhgaxzo7haf';
REVOKE ALL, GRANT OPTION FROM 'system_registry'@'localhost';

GRANT ALL PRIVILEGES ON `arrowhead`.`device` TO 'system_registry'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`system_` TO 'system_registry'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`system_registry` TO 'system_registry'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`service_definition` TO 'system_registry'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`service_interface` TO 'system_registry'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`service_registry` TO 'system_registry'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`service_registry_interface_connection` TO 'system_registry'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`authorization_intra_cloud` TO 'system_registry'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`authorization_intra_cloud_interface_connection` TO 'system_registry'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`authorization_inter_cloud` TO 'system_registry'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`authorization_inter_cloud_interface_connection` TO 'system_registry'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`logs` TO 'system_registry'@'localhost';

REVOKE ALL, GRANT OPTION FROM 'system_registry'@'%';

GRANT ALL PRIVILEGES ON `arrowhead`.`device` TO 'system_registry'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`system_` TO 'system_registry'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`system_registry` TO 'system_registry'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`service_definition` TO 'system_registry'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`service_interface` TO 'system_registry'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`service_registry` TO 'system_registry'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`service_registry_interface_connection` TO 'system_registry'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`authorization_intra_cloud` TO 'system_registry'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`authorization_intra_cloud_interface_connection` TO 'system_registry'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`authorization_inter_cloud` TO 'system_registry'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`authorization_inter_cloud_interface_connection` TO 'system_registry'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`logs` TO 'system_registry'@'%';

FLUSH PRIVILEGES;

-- Device Registry
CREATE USER IF NOT EXISTS 'device_registry'@'localhost' IDENTIFIED BY 'iooHU87hNGUalht';
CREATE USER IF NOT EXISTS 'device_registry'@'%' IDENTIFIED BY 'iooHU87hNGUalht';
REVOKE ALL, GRANT OPTION FROM 'device_registry'@'localhost';

GRANT ALL PRIVILEGES ON `arrowhead`.`device` TO 'device_registry'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`device_registry` TO 'device_registry'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`system_` TO 'device_registry'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`service_definition` TO 'device_registry'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`service_interface` TO 'device_registry'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`service_registry` TO 'device_registry'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`service_registry_interface_connection` TO 'device_registry'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`authorization_intra_cloud` TO 'device_registry'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`authorization_intra_cloud_interface_connection` TO 'device_registry'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`authorization_inter_cloud` TO 'device_registry'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`authorization_inter_cloud_interface_connection` TO 'device_registry'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`logs` TO 'device_registry'@'localhost';

REVOKE ALL, GRANT OPTION FROM 'device_registry'@'%';

GRANT ALL PRIVILEGES ON `arrowhead`.`device` TO 'device_registry'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`device_registry` TO 'device_registry'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`system_` TO 'device_registry'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`service_definition` TO 'device_registry'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`service_interface` TO 'device_registry'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`service_registry` TO 'device_registry'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`service_registry_interface_connection` TO 'device_registry'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`authorization_intra_cloud` TO 'device_registry'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`authorization_intra_cloud_interface_connection` TO 'device_registry'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`authorization_inter_cloud` TO 'device_registry'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`authorization_inter_cloud_interface_connection` TO 'device_registry'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`logs` TO 'device_registry'@'%';

FLUSH PRIVILEGES;

-- Onboarding controller
CREATE USER IF NOT EXISTS 'onboarding_controller'@'localhost' IDENTIFIED BY 'JKgh1as5f6oi7aV';
CREATE USER IF NOT EXISTS 'onboarding_controller'@'%' IDENTIFIED BY 'JKgh1as5f6oi7aV';
REVOKE ALL, GRANT OPTION FROM 'onboarding_controller'@'localhost';

GRANT ALL PRIVILEGES ON `arrowhead`.`logs` TO 'onboarding_controller'@'localhost';

REVOKE ALL, GRANT OPTION FROM 'onboarding_controller'@'%';

GRANT ALL PRIVILEGES ON `arrowhead`.`logs` TO 'onboarding_controller'@'%';

FLUSH PRIVILEGES;

-- Authorization
CREATE USER IF NOT EXISTS 'authorization'@'localhost' IDENTIFIED BY 'hqZFUkuHxhekio3';
CREATE USER IF NOT EXISTS 'authorization'@'%' IDENTIFIED BY 'hqZFUkuHxhekio3';
REVOKE ALL, GRANT OPTION FROM 'authorization'@'localhost';

GRANT ALL PRIVILEGES ON `arrowhead`.`authorization_intra_cloud` TO 'authorization'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`authorization_intra_cloud_interface_connection` TO 'authorization'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`authorization_inter_cloud` TO 'authorization'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`authorization_inter_cloud_interface_connection` TO 'authorization'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`system_` TO 'authorization'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`cloud` TO 'authorization'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`relay` TO 'authorization'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`cloud_gatekeeper_relay` TO 'authorization'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`cloud_gateway_relay` TO 'authorization'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`service_definition` TO 'authorization'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`service_interface` TO 'authorization'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`logs` TO 'authorization'@'localhost';

REVOKE ALL, GRANT OPTION FROM 'authorization'@'%';

GRANT ALL PRIVILEGES ON `arrowhead`.`authorization_intra_cloud` TO 'authorization'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`authorization_intra_cloud_interface_connection` TO 'authorization'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`authorization_inter_cloud` TO 'authorization'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`authorization_inter_cloud_interface_connection` TO 'authorization'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`system_` TO 'authorization'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`cloud` TO 'authorization'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`relay` TO 'authorization'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`cloud_gatekeeper_relay` TO 'authorization'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`cloud_gateway_relay` TO 'authorization'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`service_definition` TO 'authorization'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`service_interface` TO 'authorization'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`logs` TO 'authorization'@'%';

FLUSH PRIVILEGES;

-- Orchestrator
CREATE USER IF NOT EXISTS 'orchestrator'@'localhost' IDENTIFIED BY 'KbgD2mTr8DQ4vtc';
CREATE USER IF NOT EXISTS 'orchestrator'@'%' IDENTIFIED BY 'KbgD2mTr8DQ4vtc';
REVOKE ALL, GRANT OPTION FROM 'orchestrator'@'localhost';

GRANT ALL PRIVILEGES ON `arrowhead`.`orchestrator_store` TO 'orchestrator'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`foreign_system` TO 'orchestrator'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`system_` TO 'orchestrator'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`cloud` TO 'orchestrator'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`relay` TO 'orchestrator'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`cloud_gatekeeper_relay` TO 'orchestrator'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`cloud_gateway_relay` TO 'orchestrator'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`service_definition` TO 'orchestrator'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`service_interface` TO 'orchestrator'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`qos_reservation` TO 'orchestrator'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`logs` TO 'orchestrator'@'localhost';

REVOKE ALL, GRANT OPTION FROM 'orchestrator'@'%';

GRANT ALL PRIVILEGES ON `arrowhead`.`orchestrator_store` TO 'orchestrator'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`foreign_system` TO 'orchestrator'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`system_` TO 'orchestrator'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`cloud` TO 'orchestrator'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`relay` TO 'orchestrator'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`cloud_gatekeeper_relay` TO 'orchestrator'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`cloud_gateway_relay` TO 'orchestrator'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`service_definition` TO 'orchestrator'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`service_interface` TO 'orchestrator'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`qos_reservation` TO 'orchestrator'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`logs` TO 'orchestrator'@'%';

FLUSH PRIVILEGES;

-- Event Handler
CREATE USER IF NOT EXISTS 'event_handler'@'localhost' IDENTIFIED BY 'gRLjXbqu9YwYhfK';
CREATE USER IF NOT EXISTS 'event_handler'@'%' IDENTIFIED BY 'gRLjXbqu9YwYhfK';
REVOKE ALL, GRANT OPTION FROM 'event_handler'@'localhost';

GRANT ALL PRIVILEGES ON `arrowhead`.`event_type` TO 'event_handler'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`subscription` TO 'event_handler'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`subscription_publisher_connection` TO 'event_handler'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`system_` TO 'event_handler'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`logs` TO 'event_handler'@'localhost';

REVOKE ALL, GRANT OPTION FROM 'event_handler'@'%';

GRANT ALL PRIVILEGES ON `arrowhead`.`event_type` TO 'event_handler'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`subscription` TO 'event_handler'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`subscription_publisher_connection` TO 'event_handler'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`system_` TO 'event_handler'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`logs` TO 'event_handler'@'%';

FLUSH PRIVILEGES;

-- DataManager
CREATE USER IF NOT EXISTS 'datamanager'@'localhost' IDENTIFIED BY 'gRLjXbqu0YwYhfK';
CREATE USER IF NOT EXISTS 'datamanager'@'%' IDENTIFIED BY 'gRLjXbqu0YwYhfK';
REVOKE ALL, GRANT OPTION FROM 'datamanager'@'localhost';

GRANT ALL PRIVILEGES ON `arrowhead`.`dmhist_services` TO 'datamanager'@'localhost';
#GRANT ALL PRIVILEGES ON `arrowhead`.`dmhist_files` TO 'datamanager'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`dmhist_messages` TO 'datamanager'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`dmhist_entries` TO 'datamanager'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`logs` TO 'datamanager'@'localhost';

GRANT ALL PRIVILEGES ON `arrowhead`.`dmhist_services` TO 'datamanager'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`dmhist_files` TO 'datamanager'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`dmhist_messages` TO 'datamanager'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`dmhist_entries` TO 'datamanager'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`logs` TO 'datamanager'@'%';

FLUSH PRIVILEGES;

-- Choreographer
CREATE USER IF NOT EXISTS 'choreographer'@'localhost' IDENTIFIED BY 'Qa5yx4oBp4Y9RLX';
CREATE USER IF NOT EXISTS 'choreographer'@'%' IDENTIFIED BY 'Qa5yx4oBp4Y9RLX';
REVOKE ALL, GRANT OPTION FROM 'choreographer'@'localhost';

GRANT ALL PRIVILEGES ON `arrowhead`.`choreographer_plan` TO 'choreographer'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`choreographer_action` TO 'choreographer'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`choreographer_step` TO 'choreographer'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`choreographer_action_step_service_definition_connection` TO 'choreographer'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`choreographer_step_next_step_connection` TO 'choreographer'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`choreographer_session` TO 'choreographer'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`choreographer_running_step` TO 'choreographer'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`choreographer_worklog` TO 'choreographer'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`logs` TO 'choreographer'@'localhost';

REVOKE ALL, GRANT OPTION FROM 'choreographer'@'%';

GRANT ALL PRIVILEGES ON `arrowhead`.`choreographer_plan` TO 'choreographer'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`choreographer_action` TO 'choreographer'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`choreographer_step` TO 'choreographer'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`choreographer_step_service_definition_connection` TO 'choreographer'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`choreographer_step_next_step_connection` TO 'choreographer'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`choreographer_session` TO 'choreographer'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`choreographer_running_step` TO 'choreographer'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`choreographer_worklog` TO 'choreographer'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`logs` TO 'choreographer'@'%';

FLUSH PRIVILEGES;

-- Gatekeeper
CREATE USER IF NOT EXISTS 'gatekeeper'@'localhost' IDENTIFIED BY 'fbJKYzKhU5t8QtT';
CREATE USER IF NOT EXISTS 'gatekeeper'@'%' IDENTIFIED BY 'fbJKYzKhU5t8QtT';
REVOKE ALL, GRANT OPTION FROM 'gatekeeper'@'localhost';

GRANT ALL PRIVILEGES ON `arrowhead`.`cloud` TO 'gatekeeper'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`relay` TO 'gatekeeper'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`system_` TO 'gatekeeper'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`service_definition` TO 'gatekeeper'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`cloud_gatekeeper_relay` TO 'gatekeeper'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`cloud_gateway_relay` TO 'gatekeeper'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`authorization_inter_cloud` TO 'gatekeeper'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`authorization_inter_cloud_interface_connection` TO 'gatekeeper'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`foreign_system` TO 'gatekeeper'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`logs` TO 'gatekeeper'@'localhost';

REVOKE ALL, GRANT OPTION FROM 'gatekeeper'@'%';

GRANT ALL PRIVILEGES ON `arrowhead`.`cloud` TO 'gatekeeper'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`relay` TO 'gatekeeper'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`system_` TO 'gatekeeper'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`service_definition` TO 'gatekeeper'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`cloud_gatekeeper_relay` TO 'gatekeeper'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`cloud_gateway_relay` TO 'gatekeeper'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`authorization_inter_cloud` TO 'gatekeeper'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`authorization_inter_cloud_interface_connection` TO 'gatekeeper'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`foreign_system` TO 'gatekeeper'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`logs` TO 'gatekeeper'@'%';

FLUSH PRIVILEGES;

-- Gateway
CREATE USER IF NOT EXISTS 'gateway'@'localhost' IDENTIFIED BY 'LfiSM9DpGfDEP5g';
CREATE USER IF NOT EXISTS 'gateway'@'%' IDENTIFIED BY 'LfiSM9DpGfDEP5g';
REVOKE ALL, GRANT OPTION FROM 'gateway'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`logs` TO 'gateway'@'localhost';

REVOKE ALL, GRANT OPTION FROM 'gateway'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`logs` TO 'gateway'@'%';

FLUSH PRIVILEGES;

-- Certificate Authority
CREATE USER IF NOT EXISTS 'certificate_authority'@'localhost' IDENTIFIED BY 'FsdG6Kgf9QpPfv2';
CREATE USER IF NOT EXISTS 'certificate_authority'@'%' IDENTIFIED BY 'FsdG6Kgf9QpPfv2';
REVOKE ALL, GRANT OPTION FROM 'certificate_authority'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`logs` TO 'certificate_authority'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`ca_certificate` TO 'certificate_authority'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`ca_trusted_key` TO 'certificate_authority'@'localhost';

REVOKE ALL, GRANT OPTION FROM 'certificate_authority'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`logs` TO 'certificate_authority'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`ca_certificate` TO 'certificate_authority'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`ca_trusted_key` TO 'certificate_authority'@'%';

FLUSH PRIVILEGES;

-- QoS Monitor
CREATE USER IF NOT EXISTS 'qos_monitor'@'localhost' IDENTIFIED BY 'RLY3UEx6nx4kSXy';
CREATE USER IF NOT EXISTS 'qos_monitor'@'%' IDENTIFIED BY 'RLY3UEx6nx4kSXy';
REVOKE ALL, GRANT OPTION FROM 'qos_monitor'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`qos_intra_measurement` TO 'qos_monitor'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`qos_intra_ping_measurement` TO 'qos_monitor'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`qos_intra_ping_measurement_log` TO 'qos_monitor'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`qos_intra_ping_measurement_log_details` TO 'qos_monitor'@'localhost';

GRANT ALL PRIVILEGES ON `arrowhead`.`qos_inter_direct_measurement` TO 'qos_monitor'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`qos_inter_direct_ping_measurement` TO 'qos_monitor'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`qos_inter_direct_ping_measurement_log` TO 'qos_monitor'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`qos_inter_direct_ping_measurement_log_details` TO 'qos_monitor'@'localhost';

GRANT ALL PRIVILEGES ON `arrowhead`.`qos_inter_relay_measurement` TO 'qos_monitor'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`qos_inter_relay_echo_measurement` TO 'qos_monitor'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`qos_inter_relay_echo_measurement_log` TO 'qos_monitor'@'localhost';

GRANT SELECT ON `arrowhead`.`system_` TO 'qos_monitor'@'localhost';
GRANT SELECT ON `arrowhead`.`cloud` TO 'qos_monitor'@'localhost';
GRANT SELECT ON `arrowhead`.`relay` TO 'qos_monitor'@'localhost';
GRANT SELECT ON `arrowhead`.`cloud_gatekeeper_relay` TO 'qos_monitor'@'localhost';
GRANT SELECT ON `arrowhead`.`cloud_gateway_relay` TO 'qos_monitor'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`logs` TO 'qos_monitor'@'localhost';

REVOKE ALL, GRANT OPTION FROM 'qos_monitor'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`qos_intra_measurement` TO 'qos_monitor'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`qos_intra_ping_measurement` TO 'qos_monitor'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`qos_intra_ping_measurement_log` TO 'qos_monitor'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`qos_intra_ping_measurement_log_details` TO 'qos_monitor'@'%';

GRANT ALL PRIVILEGES ON `arrowhead`.`qos_inter_direct_measurement` TO 'qos_monitor'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`qos_inter_direct_ping_measurement` TO 'qos_monitor'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`qos_inter_direct_ping_measurement_log` TO 'qos_monitor'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`qos_inter_direct_ping_measurement_log_details` TO 'qos_monitor'@'%';

GRANT ALL PRIVILEGES ON `arrowhead`.`qos_inter_relay_measurement` TO 'qos_monitor'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`qos_inter_relay_echo_measurement` TO 'qos_monitor'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`qos_inter_relay_echo_measurement_log` TO 'qos_monitor'@'%';

GRANT SELECT ON `arrowhead`.`system_` TO 'qos_monitor'@'%';
GRANT SELECT ON `arrowhead`.`cloud` TO 'qos_monitor'@'%';
GRANT SELECT ON `arrowhead`.`relay` TO 'qos_monitor'@'%';
GRANT SELECT ON `arrowhead`.`cloud_gatekeeper_relay` TO 'qos_monitor'@'%';
GRANT SELECT ON `arrowhead`.`cloud_gateway_relay` TO 'qos_monitor'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`logs` TO 'qos_monitor'@'%';

FLUSH PRIVILEGES;

-- Translator
CREATE USER IF NOT EXISTS 'translator'@'localhost' IDENTIFIED BY 'wozYpV58G0HUkbL';
CREATE USER IF NOT EXISTS 'translator'@'%' IDENTIFIED BY 'wozYpV58G0HUkbL';
REVOKE ALL, GRANT OPTION FROM 'translator'@'localhost';
GRANT ALL PRIVILEGES ON `arrowhead`.`logs` TO 'translator'@'localhost';

REVOKE ALL, GRANT OPTION FROM 'translator'@'%';
GRANT ALL PRIVILEGES ON `arrowhead`.`logs` TO 'translator'@'%';

FLUSH PRIVILEGES;
