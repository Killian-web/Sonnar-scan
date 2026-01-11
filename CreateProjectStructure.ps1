# Define base directory
$baseDir = "C:\Users\wadgu\OneDrive\Desktop\Devops Projects\Functional_apps\Bank_app_1\transaction-service"

# 1. Create the pom.xml file
$pomContent = '<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 
         http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>2.7.18</version>
        <relativePath/>
    </parent>

    <groupId>com.enco</groupId>
    <artifactId>transaction-service</artifactId>
    <version>1.0.0</version>
    <name>transaction-service</name>
    <description>Transaction Service for Bank Application</description>

    <properties>
        <java.version>11</java.version>
    </properties>

    <dependencies>
        <!-- Spring Boot Starters -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-data-jpa</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-validation</artifactId>
        </dependency>
        
        <!-- Database -->
        <dependency>
            <groupId>org.postgresql</groupId>
            <artifactId>postgresql</artifactId>
            <scope>runtime</scope>
        </dependency>
        
        <!-- Flyway for migrations -->
        <dependency>
            <groupId>org.flywaydb</groupId>
            <artifactId>flyway-core</artifactId>
        </dependency>
        
        <!-- Lombok -->
        <dependency>
            <groupId>org.projectlombok</groupId>
            <artifactId>lombok</artifactId>
            <optional>true</optional>
        </dependency>
        
        <!-- Testing -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>
    </dependencies>

    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
            </plugin>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-compiler-plugin</artifactId>
                <configuration>
                    <source>11</source>
                    <target>11</target>
                    <annotationProcessorPaths>
                        <path>
                            <groupId>org.projectlombok</groupId>
                            <artifactId>lombok</artifactId>
                            <version>1.18.30</version>
                        </path>
                    </annotationProcessorPaths>
                </configuration>
            </plugin>
        </plugins>
    </build>
</project>'

Set-Content -Path "$baseDir\pom.xml" -Value $pomContent
Write-Host "Created pom.xml" -ForegroundColor Green

# 2. Create TransactionApplication.java
$transactionAppContent = 'package com.enco.transaction;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class TransactionApplication {
    public static void main(String[] args) {
        SpringApplication.run(TransactionApplication.class, args);
    }
}'

Set-Content -Path "$baseDir\src\main\java\com\enco\transaction\TransactionApplication.java" -Value $transactionAppContent
Write-Host "Created TransactionApplication.java" -ForegroundColor Green

# 3. Create Transaction.java (Entity)
$transactionEntityContent = 'package com.enco.transaction.model;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import javax.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "transactions")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Transaction {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "account_id", nullable = false)
    private String accountId;
    
    @Column(name = "customer_id", nullable = false)
    private String customerId;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private TransactionType type;
    
    @Column(nullable = false)
    private Double amount;
    
    @Column(name = "balance_before")
    private Double balanceBefore;
    
    @Column(name = "balance_after")
    private Double balanceAfter;
    
    @Column(length = 500)
    private String description;
    
    @Column(name = "created_at")
    private LocalDateTime createdAt;
    
    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }
}'

Set-Content -Path "$baseDir\src\main\java\com\enco\transaction\model\Transaction.java" -Value $transactionEntityContent
Write-Host "Created Transaction.java" -ForegroundColor Green

# 4. Create TransactionType.java
$transactionTypeContent = 'package com.enco.transaction.model;

public enum TransactionType {
    DEPOSIT,
    WITHDRAWAL,
    TRANSFER,
    PAYMENT
}'

Set-Content -Path "$baseDir\src\main\java\com\enco\transaction\model\TransactionType.java" -Value $transactionTypeContent
Write-Host "Created TransactionType.java" -ForegroundColor Green

# 5. Create TransactionRequest.java
$transactionRequestContent = 'package com.enco.transaction.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import javax.validation.constraints.DecimalMin;
import javax.validation.constraints.NotNull;
import javax.validation.constraints.Size;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TransactionRequest {
    @NotNull(message = "Account ID is required")
    private String accountId;
    
    @NotNull(message = "Customer ID is required")
    private String customerId;
    
    @NotNull(message = "Amount is required")
    @DecimalMin(value = "0.01", message = "Amount must be greater than 0")
    private Double amount;
    
    @Size(max = 500, message = "Description cannot exceed 500 characters")
    private String description;
    
    @NotNull(message = "Transaction type is required")
    private String transactionType;
}'

Set-Content -Path "$baseDir\src\main\java\com\enco\transaction\dto\TransactionRequest.java" -Value $transactionRequestContent
Write-Host "Created TransactionRequest.java" -ForegroundColor Green

# 6. Create TransactionResponse.java
$transactionResponseContent = 'package com.enco.transaction.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TransactionResponse {
    private Long id;
    private String accountId;
    private String customerId;
    private String type;
    private Double amount;
    private Double balanceBefore;
    private Double balanceAfter;
    private String description;
    private LocalDateTime createdAt;
}'

Set-Content -Path "$baseDir\src\main\java\com\enco\transaction\dto\TransactionResponse.java" -Value $transactionResponseContent
Write-Host "Created TransactionResponse.java" -ForegroundColor Green

# 7. Create TransactionRepository.java
$repositoryContent = 'package com.enco.transaction.repository;

import com.enco.transaction.model.Transaction;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface TransactionRepository extends JpaRepository<Transaction, Long> {
    List<Transaction> findByAccountId(String accountId);
    List<Transaction> findByCustomerId(String customerId);
}'

Set-Content -Path "$baseDir\src\main\java\com\enco\transaction\repository\TransactionRepository.java" -Value $repositoryContent
Write-Host "Created TransactionRepository.java" -ForegroundColor Green

# 8. Create TransactionService.java (Interface)
$serviceInterfaceContent = 'package com.enco.transaction.service;

import com.enco.transaction.dto.TransactionRequest;
import com.enco.transaction.dto.TransactionResponse;
import java.util.List;

public interface TransactionService {
    TransactionResponse processTransaction(TransactionRequest request);
    List<TransactionResponse> getTransactionsByAccount(String accountId);
    TransactionResponse getTransactionById(Long id);
    List<TransactionResponse> getAllTransactions();
}'

Set-Content -Path "$baseDir\src\main\java\com\enco\transaction\service\TransactionService.java" -Value $serviceInterfaceContent
Write-Host "Created TransactionService.java" -ForegroundColor Green

# 9. Create TransactionProcessor.java
$processorInterfaceContent = 'package com.enco.transaction.service;

import com.enco.transaction.dto.TransactionRequest;
import com.enco.transaction.model.Transaction;

public interface TransactionProcessor {
    Transaction process(TransactionRequest request);
}'

Set-Content -Path "$baseDir\src\main\java\com\enco\transaction\service\TransactionProcessor.java" -Value $processorInterfaceContent
Write-Host "Created TransactionProcessor.java" -ForegroundColor Green

# 10. Create TransactionServiceImpl.java
$serviceImplContent = 'package com.enco.transaction.service;

import com.enco.transaction.dto.TransactionRequest;
import com.enco.transaction.dto.TransactionResponse;
import com.enco.transaction.model.Transaction;
import com.enco.transaction.repository.TransactionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class TransactionServiceImpl implements TransactionService {
    
    private final TransactionRepository transactionRepository;
    private final Map<String, TransactionProcessor> processors;
    
    @Override
    public TransactionResponse processTransaction(TransactionRequest request) {
        TransactionProcessor processor = processors.get(request.getTransactionType().toLowerCase() + "Processor");
        if (processor == null) {
            throw new IllegalArgumentException("Unsupported transaction type: " + request.getTransactionType());
        }
        
        Transaction transaction = processor.process(request);
        Transaction savedTransaction = transactionRepository.save(transaction);
        
        return mapToResponse(savedTransaction);
    }
    
    @Override
    public List<TransactionResponse> getTransactionsByAccount(String accountId) {
        return transactionRepository.findByAccountId(accountId)
                .stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }
    
    @Override
    public TransactionResponse getTransactionById(Long id) {
        Transaction transaction = transactionRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Transaction not found with id: " + id));
        return mapToResponse(transaction);
    }
    
    @Override
    public List<TransactionResponse> getAllTransactions() {
        return transactionRepository.findAll()
                .stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }
    
    private TransactionResponse mapToResponse(Transaction transaction) {
        return TransactionResponse.builder()
                .id(transaction.getId())
                .accountId(transaction.getAccountId())
                .customerId(transaction.getCustomerId())
                .type(transaction.getType().name())
                .amount(transaction.getAmount())
                .balanceBefore(transaction.getBalanceBefore())
                .balanceAfter(transaction.getBalanceAfter())
                .description(transaction.getDescription())
                .createdAt(transaction.getCreatedAt())
                .build();
    }
}'

Set-Content -Path "$baseDir\src\main\java\com\enco\transaction\service\TransactionServiceImpl.java" -Value $serviceImplContent
Write-Host "Created TransactionServiceImpl.java" -ForegroundColor Green

# 11. Create DepositProcessor.java
$depositProcessorContent = 'package com.enco.transaction.service;

import com.enco.transaction.dto.TransactionRequest;
import com.enco.transaction.model.Transaction;
import com.enco.transaction.model.TransactionType;
import org.springframework.stereotype.Component;

@Component("depositProcessor")
public class DepositProcessor implements TransactionProcessor {
    
    @Override
    public Transaction process(TransactionRequest request) {
        double currentBalance = getCurrentBalance(request.getAccountId());
        double newBalance = currentBalance + request.getAmount();
        
        return Transaction.builder()
                .accountId(request.getAccountId())
                .customerId(request.getCustomerId())
                .type(TransactionType.DEPOSIT)
                .amount(request.getAmount())
                .balanceBefore(currentBalance)
                .balanceAfter(newBalance)
                .description(request.getDescription() != null ? request.getDescription() : "Deposit transaction")
                .build();
    }
    
    private double getCurrentBalance(String accountId) {
        // Mock balance
        return 1000.0;
    }
}'

Set-Content -Path "$baseDir\src\main\java\com\enco\transaction\service\DepositProcessor.java" -Value $depositProcessorContent
Write-Host "Created DepositProcessor.java" -ForegroundColor Green

# 12. Create WithdrawProcessor.java
$withdrawProcessorContent = 'package com.enco.transaction.service;

import com.enco.transaction.dto.TransactionRequest;
import com.enco.transaction.model.Transaction;
import com.enco.transaction.model.TransactionType;
import org.springframework.stereotype.Component;

@Component("withdrawalProcessor")
public class WithdrawProcessor implements TransactionProcessor {
    
    @Override
    public Transaction process(TransactionRequest request) {
        double currentBalance = getCurrentBalance(request.getAccountId());
        
        if (currentBalance < request.getAmount()) {
            throw new RuntimeException("Insufficient funds for account: " + request.getAccountId());
        }
        
        double newBalance = currentBalance - request.getAmount();
        
        return Transaction.builder()
                .accountId(request.getAccountId())
                .customerId(request.getCustomerId())
                .type(TransactionType.WITHDRAWAL)
                .amount(request.getAmount())
                .balanceBefore(currentBalance)
                .balanceAfter(newBalance)
                .description(request.getDescription() != null ? request.getDescription() : "Withdrawal transaction")
                .build();
    }
    
    private double getCurrentBalance(String accountId) {
        // Mock balance
        return 1000.0;
    }
}'

Set-Content -Path "$baseDir\src\main\java\com\enco\transaction\service\WithdrawProcessor.java" -Value $withdrawProcessorContent
Write-Host "Created WithdrawProcessor.java" -ForegroundColor Green

# 13. Create TransactionController.java
$controllerContent = 'package com.enco.transaction.controller;

import com.enco.transaction.dto.TransactionRequest;
import com.enco.transaction.dto.TransactionResponse;
import com.enco.transaction.service.TransactionService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import javax.validation.Valid;
import java.util.List;

@RestController
@RequestMapping("/api/transactions")
@RequiredArgsConstructor
public class TransactionController {
    
    private final TransactionService transactionService;
    
    @PostMapping
    public ResponseEntity<TransactionResponse> createTransaction(@Valid @RequestBody TransactionRequest request) {
        TransactionResponse response = transactionService.processTransaction(request);
        return new ResponseEntity<>(response, HttpStatus.CREATED);
    }
    
    @GetMapping("/account/{accountId}")
    public ResponseEntity<List<TransactionResponse>> getTransactionsByAccount(@PathVariable String accountId) {
        List<TransactionResponse> transactions = transactionService.getTransactionsByAccount(accountId);
        return ResponseEntity.ok(transactions);
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<TransactionResponse> getTransactionById(@PathVariable Long id) {
        TransactionResponse transaction = transactionService.getTransactionById(id);
        return ResponseEntity.ok(transaction);
    }
    
    @GetMapping
    public ResponseEntity<List<TransactionResponse>> getAllTransactions() {
        List<TransactionResponse> transactions = transactionService.getAllTransactions();
        return ResponseEntity.ok(transactions);
    }
}'

Set-Content -Path "$baseDir\src\main\java\com\enco\transaction\controller\TransactionController.java" -Value $controllerContent
Write-Host "Created TransactionController.java" -ForegroundColor Green

# 14. Create application.yml
$appYmlContent = 'server:
  port: 8082

spring:
  application:
    name: transaction-service
  
  datasource:
    url: jdbc:postgresql://localhost:5432/transaction_db
    username: postgres
    password: postgres
  
  jpa:
    hibernate:
      ddl-auto: update
    show-sql: true'

Set-Content -Path "$baseDir\src\main\resources\application.yml" -Value $appYmlContent
Write-Host "Created application.yml" -ForegroundColor Green

# 15. Create minimal other files
$files = @(
    @{Path = "src\main\resources\application-dev.yml"; Content = "spring: {}"},
    @{Path = "src\main\resources\application-staging.yml"; Content = "spring: {}"},
    @{Path = "src\main\resources\application-prod.yml"; Content = "spring: {}"},
    @{Path = "src\main\resources\db\migration\V1__create_transactions_table.sql"; Content = "CREATE TABLE transactions (id SERIAL PRIMARY KEY);"},
    @{Path = "src\test\resources\application-test.yml"; Content = "spring: {}"},
    @{Path = "src\test\java\com\enco\transaction\controller\TransactionControllerTest.java"; Content = "package com.enco.transaction.controller;"},
    @{Path = "src\test\java\com\enco\transaction\service\TransactionServiceTest.java"; Content = "package com.enco.transaction.service;"},
    @{Path = "src\test\java\com\enco\transaction\service\DepositProcessorTest.java"; Content = "package com.enco.transaction.service;"},
    @{Path = "src\test\java\com\enco\transaction\service\WithdrawProcessorTest.java"; Content = "package com.enco.transaction.service;"},
    @{Path = "src\test\java\com\enco\transaction\integration\TransactionServiceIntegrationTest.java"; Content = "package com.enco.transaction.integration;"},
    @{Path = "Dockerfile"; Content = "FROM openjdk:11"},
    @{Path = ".dockerignore"; Content = "*.jar"},
    @{Path = "README.md"; Content = "# Transaction Service"},
    @{Path = ".gitignore"; Content = "target/"},
    @{Path = "deployment\service.yaml"; Content = "apiVersion: v1"}
)

foreach ($file in $files) {
    $fullPath = Join-Path $baseDir $file.Path
    $parentDir = Split-Path $fullPath -Parent
    if (-not (Test-Path $parentDir)) {
        New-Item -ItemType Directory -Path $parentDir -Force
    }
    Set-Content -Path $fullPath -Value $file.Content
    Write-Host "Created $($file.Path)" -ForegroundColor Cyan
}

Write-Host "`n===========================================" -ForegroundColor Green
Write-Host "ALL FILES CREATED SUCCESSFULLY!" -ForegroundColor Green
Write-Host "===========================================" -ForegroundColor Green
Write-Host "`nTo build the project:" -ForegroundColor Yellow
Write-Host "1. Run: mvn clean compile" -ForegroundColor Yellow
Write-Host "2. Install Lombok plugin in your IDE" -ForegroundColor Yellow
Write-Host "3. Enable annotation processing" -ForegroundColor Yellow