package com.enco.transaction.service;

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
}
