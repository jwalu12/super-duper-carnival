#!/usr/bin/env python3
"""Illustrative ADS operator-fee and liquid-staking calculator."""

from __future__ import annotations


def calculate_rewards(
    fees_processed_by_node_ads: float,
    burned_network_fees_ads: float,
    your_ads_balance: float,
    active_ads_balance: float,
    operator_fee_rate: float = 0.20,
) -> dict[str, float]:
    if min(
        fees_processed_by_node_ads,
        burned_network_fees_ads,
        your_ads_balance,
        active_ads_balance,
    ) < 0:
        raise ValueError("Values cannot be negative")
    if not 0 <= operator_fee_rate <= 1:
        raise ValueError("Operator fee rate must be between 0 and 1")

    operator_reward = fees_processed_by_node_ads * operator_fee_rate
    balance_share = (
        your_ads_balance / active_ads_balance if active_ads_balance else 0.0
    )
    staking_reward = burned_network_fees_ads * balance_share

    return {
        "operator_reward_ads": operator_reward,
        "staking_reward_ads": staking_reward,
        "combined_reward_ads": operator_reward + staking_reward,
        "active_balance_share_percent": balance_share * 100,
    }


def read_nonnegative(prompt: str) -> float:
    value = float(input(prompt))
    if value < 0:
        raise ValueError("Value cannot be negative")
    return value


def main() -> None:
    print("ADSHARES REWARDS ESTIMATOR")
    print("This is an illustration, not a promise of income.")
    try:
        node_fees = read_nonnegative(
            "Transaction fees processed by your node during the period (ADS): "
        )
        burned_fees = read_nonnegative(
            "Network fees returned through the staking cycle (ADS): "
        )
        balance = read_nonnegative("Your active ADS balance: ")
        active_balance = read_nonnegative("Total active ADS balance: ")
        result = calculate_rewards(node_fees, burned_fees, balance, active_balance)
    except ValueError as error:
        raise SystemExit(f"Invalid input: {error}") from error

    print(f"Operator reward: {result['operator_reward_ads']:.8f} ADS")
    print(f"Liquid-staking estimate: {result['staking_reward_ads']:.8f} ADS")
    print(f"Combined estimate: {result['combined_reward_ads']:.8f} ADS")
    print(
        "Share of active balance: "
        f"{result['active_balance_share_percent']:.6f}%"
    )


if __name__ == "__main__":
    main()
