address admin {

module tesstoken {
    use aptos_framework::coin;
    use std::signer;
    use std::string;

    struct TESS{}

    struct CoinCapabilities<phantom TESS> has key {
        mint_capability: coin::MintCapability<TESS>,
        burn_capability: coin::BurnCapability<TESS>,
        freeze_capability: coin::FreezeCapability<TESS>,
    }

    const E_NO_ADMIN: u64 = 0;
    const E_NO_CAPABILITIES: u64 = 1;
    const E_HAS_CAPABILITIES: u64 = 2;

    public entry fun init_tess(account: &signer) {
        let (burn_capability, freeze_capability, mint_capability) = coin::initialize<TESS>(
            account,
            string::utf8(b"Tess Token"),
            string::utf8(b"TESS"),
            18,
            true,
        );

        assert!(signer::address_of(account) == @admin, E_NO_ADMIN);
        assert!(!exists<CoinCapabilities<TESS>>(@admin), E_HAS_CAPABILITIES);

        move_to<CoinCapabilities<TESS>>(account, CoinCapabilities<TESS>{mint_capability, burn_capability, freeze_capability});
    }

    public entry fun mint<TESS>(account: &signer, user: address, amount: u64) acquires CoinCapabilities {
        let account_address = signer::address_of(account);
        assert!(account_address == @admin, E_NO_ADMIN);
        assert!(exists<CoinCapabilities<TESS>>(account_address), E_NO_CAPABILITIES);
        let mint_capability = &borrow_global<CoinCapabilities<TESS>>(account_address).mint_capability;
        let coins = coin::mint<TESS>(amount, mint_capability);
        coin::deposit(user, coins)
    }

    public entry fun burn<FANV4>(coins:coin::Coin<TESS>) acquires CoinCapabilities {
        let burn_capability = &borrow_global<CoinCapabilities<TESS>>(@admin).burn_capability;
        coin::burn<TESS>(coins, burn_capability);
    }
}
}