package com.enco.transaction.service;

import com.enco.transaction.dto.TransactionRequest;
import com.enco.transaction.dto.TransactionResponse;
import java.util.List;

public interface TransactionService {
    TransactionResponse processTransaction(TransactionRequest request);
    List<TransactionResponse> getTransactionsByAccount(String accountId);
    TransactionResponse getTransactionById(Long id);
    List<TransactionResponse> getAllTransactions();
}
