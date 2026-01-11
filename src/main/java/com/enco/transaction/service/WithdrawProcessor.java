package com.enco.transaction.service;

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
}
