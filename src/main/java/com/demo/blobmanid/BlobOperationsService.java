package com.demo.blobmanid;

import java.io.BufferedInputStream;
import java.io.IOException;
import java.util.Objects;

import com.azure.identity.DefaultAzureCredentialBuilder;
import com.azure.storage.blob.BlobClient;
import com.azure.storage.blob.BlobClientBuilder;
import com.azure.storage.blob.BlobServiceClient;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

/**
 * The service class responsible to connect to the BlobServiceClient and create containers/blobs
 */
@Service
@Slf4j
@RequiredArgsConstructor
public class BlobOperationsService {
    /**
     * The data path to keep the uploaded files locally
     */
    private static final String PATH = "./data";
    /**
     * The container name to be created,
     */
    private static final String CONTAINER_NAME = "container07061905";
    private final BlobServiceClient blobServiceClient;

    public void createContainer() {
        log.debug("A container with name {} will be created", CONTAINER_NAME);
        blobServiceClient.createBlobContainerIfNotExists(CONTAINER_NAME);
        log.debug("A container with name {} has been created", CONTAINER_NAME);
    }

    public void uploadBlob(MultipartFile file) throws IOException {
        String endpoint = "https://testexample12318.blob.core.windows.net";
        String blobName = file.getOriginalFilename();

        Objects.requireNonNull(blobName, "'blobName' cannot be null.");
        BlobClient blobClient = new BlobClientBuilder()
                .endpoint(endpoint)
                .containerName(CONTAINER_NAME)
                .blobName(blobName)
                .credential(new DefaultAzureCredentialBuilder().build())
                .buildClient();

        log.info(blobClient.getAccountName());

        try (BufferedInputStream bis = new BufferedInputStream(file.getInputStream())) {
            blobClient.upload(bis, file.getSize(), true);
        } catch (IOException e) {
            log.error("Exception while writing to blob", e);
            e.printStackTrace();
            throw e;
        }
    }
}
