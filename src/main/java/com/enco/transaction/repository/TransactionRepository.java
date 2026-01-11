package com.enco.transaction.repository;

import com.enco.transaction.model.Transaction;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface TransactionRepository extends JpaRepository<Transaction, Long> {
    List<Transaction> findByAccountId(String accountId);
    List<Transaction> findByCustomerId(String customerId);
}
