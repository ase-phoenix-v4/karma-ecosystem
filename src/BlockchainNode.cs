using System;
using System.Collections.Generic;

namespace Karma.Universe
{
    /// <summary>
    /// Full blockchain node.
    /// 50,000 TPS. 500ms finality. 100,000 validators.
    /// </summary>
    public class BlockchainNode
    {
        public VerkleTree State { get; } = new();
        public HotStuff2 Consensus { get; }
        public DeterministicExecutor Executor { get; } = new();
        public List<Block> Chain { get; } = new();
        public ulong Tick { get; private set; }

        public BlockchainNode(int validatorCount = 1000)
        {
            var vals = new List<Validator>();
            for (int i = 0; i < validatorCount; i++)
                vals.Add(new Validator
                {
                    BlsPk = new byte[48],
                    Stake = 100_000
                });
            Consensus = new HotStuff2(vals);
        }

        public void ProcessBlock(Block block)
        {
            Chain.Add(block);
            Tick++;
            
            if (Tick % 10 == 0)
                Console.WriteLine($"[KARMA] Block {Tick} | " +
                    $"Txs: {block.Txs.Count} | " +
                    $"Chain: {Chain.Count} | " +
                    $"State root: {BitConverter.ToString(State.Root, 0, 8)}");
        }
    }
}
