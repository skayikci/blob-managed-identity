package com.demo.blobmanid;

import org.springframework.boot.context.properties.ConfigurationProperties;

/**
 * Properties used to create a BlobServiceClient Bean
 *
 * @param connectionString the created SAS connection string
 */
@ConfigurationProperties(prefix = "com.cosmos")
public record BlobServiceClientProperties(String connectionString, String tenantId) {
}
