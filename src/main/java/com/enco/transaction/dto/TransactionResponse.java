package com.enco.transaction.dto;

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
}
