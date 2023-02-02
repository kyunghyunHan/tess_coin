address admin {
    module tess_token{
        use aptos_framework::coin;
        use std::signer;
        use std::string;

        struct TESS{}

        struct CoinCapabilities<phantom TESS>has key{
            mint_capability:coin::MintCapability<TESS>,
            burn_capability:coin::BurnCapability<TESS>,
            freeze_capability:coin::FreezeCapability<TESS>,
        }

        const E_NO_ADMIN:u64= 0;
        const E_NO_CAPABILITIES:u64=1;
        const E_HAS_CAPABILITIES:u64=2;
        public entry fun init_fan(account:&signer){
            let (burn_capability,freeze_capability,mint_capability)= coin::initialize<TESS>(
                account,
                string::utf8(b"Tess Token"),
                string::utf8(b"TESS"),
                18,
                true,
            );
            assert!(signer::address_of(account)==@admin,E_NO_ADMIN);
            assert!(!exists<CoinCapabilities<TESS>>(@admin),E_HAS_CAPABILITIES);

            move_to<CoinCapabilities<TESS>>(account,CoinCapabilities<TESS>{mint_capability,burn_capability,freeze_capability});

        }
    }
}