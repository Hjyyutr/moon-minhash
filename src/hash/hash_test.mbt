///|
test "test uint64 literal" {
  let a : UInt64 = 2147483647UL
  let b : UInt64 = 0x736f6d6570736575UL
  let c : UInt64 = 100UL
  let d : UInt = 100U
  let _ = a + b + c + d.to_uint64()
}
