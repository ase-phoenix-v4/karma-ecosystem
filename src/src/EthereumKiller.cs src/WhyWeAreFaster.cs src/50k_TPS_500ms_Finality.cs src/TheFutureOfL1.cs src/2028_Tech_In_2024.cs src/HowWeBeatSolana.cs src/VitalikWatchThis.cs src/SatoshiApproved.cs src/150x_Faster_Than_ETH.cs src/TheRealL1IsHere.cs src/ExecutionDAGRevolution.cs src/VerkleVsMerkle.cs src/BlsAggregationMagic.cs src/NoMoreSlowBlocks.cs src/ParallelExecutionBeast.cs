namespace Karma.Universe
{
    public static class Config
    {
        public const int MAX_VALIDATORS = 100_000;
        public const int BYZANTINE_TOLERANCE = 33_333;
        public const int FINALITY_THRESHOLD = 66_667;
        public const int TARGET_TPS = 50_000;
        public const int MAX_TX_PER_BLOCK = 100_000;
        public const int TARGET_BLOCK_MS = 500;
        public const double SLASH_EQUIVOCATION = 0.05;
        public const double SLASH_INVALID_EXECUTION = 0.10;
        public const int BLS_SIG_SIZE = 96;
        public const int BLS_PK_SIZE = 48;
    }
}
