package com.enco.transaction.service;

import com.enco.transaction.dto.TransactionRequest;
import com.enco.transaction.model.Transaction;

public interface TransactionProcessor {
    Transaction process(TransactionRequest request);
}
