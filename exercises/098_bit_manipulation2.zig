//
// Another useful application for bit manipulation is setting bits as flags.
// This is especially useful when processing lists of something and storing
// the states of the entries, e.g. a list of numbers and for each prime
// number a flag is set.
//
// As an example, let's take the Pangram exercise from Exercism:
// https://exercism.org/tracks/zig/exercises/pangram
//
// A pangram is a sentence using every letter of the alphabet at least once.
// It is case insensitive, so it doesn't matter if a letter is lower-case
// or upper-case. The best known English pangram is:
//
//           "The quick brown fox jumps over the lazy dog."
//
// There are several ways to select the letters that appear in the pangram
// (and it doesn't matter if they appear once or several times).
//
// For example, you could take an array of bool and set the value to 'true'
// for each letter in the order of the alphabet (a=0; b=1; etc.) found in
// the sentence. However, this is neither memory efficient nor particularly
// fast. Instead we choose a simpler approach that is very similar in principle:
// We define a variable with at least 26 bits (e.g. u32) and set the bit for
// each letter that is found in the corresponding position.
//
// Zig provides functions for this in the standard library, but we prefer to
// solve it without these extras, after all we want to learn something.
//
const std = @import("std");
const ascii = std.ascii;
const print = std.debug.print;

pub fn main() !void {
    // let's check the pangram
    print("Is this a pangram? {?}!\n", .{isPangram("The quick brown fox jumps over the lazy dog.")});
}

fn isPangram(str: []const u8) bool {
    // first we check if the string has at least 26 characters
    if (str.len < 26) return false;

    // we use a 32 bit variable of which we need 26 bits
    var bits: u32 = 0;

    // loop about all characters in the string
    for (str) |c| {
        // if the character is an alphabetical character
        if (ascii.isASCII(c) and ascii.isAlphabetic(c)) {
            // then we set the bit at the position
            //
            // to do this, we use a little trick:
            // since the letters in the ASCII table start at 65
            // and are numbered sequentially, we simply subtract the
            // first letter (in this case the 'a') from the character
            // found, and thus get the position of the desired bit
            bits |= @as(u32, 1) << @truncate(ascii.toLower(c) - 'a');
        }
    }
    // last we return the comparison if all 26 bits are set,
    // and if so, we know the given string is a pangram
    //
    // but what do we have to compare?
    return bits == 0x03FFFFFF; // 26 1-bits
    // Solution:
    // We have 26 english letters, so we need 26 spots that we can mark with 1.
    // We need a u32 which has 32 bits (spots) available, a u16 for example has 16 bits which is less then 26 and is not enough.
    // We subtract whatever letter we get with 'a' to essentially map each letter we receive from 0 to 25.
    // Since the bit operation is on a u32, truncate inferes the u32 and makes sure if we receive for example a u64,
    // removes the "left" (significant) 32 bits to result in a u32 so it can safely do the operation.
    // The @as(u32, 1) is 00000000 00000000 00000000 00000001
    // If we receive 'a' then we shift left by 0 (no shift basically)
    // If we receive 'b' then the operation is: 00000000 00000000 00000000 00000001 << 1, we shift by 1 position and results to:
    // 00000000 00000000 00000000 00000010
    // zyx...                       ...cba
    //
    // The |= operation if we receive 'a' will be:
    // 00000000 00000000 00000000 00000000 (bits variable)
    // 00000000 00000000 00000000 00000001 (letter we received)
    // -----------------------------------
    // 00000000 00000000 00000000 00000001 (new bits value)
    //
    // And if we receive now 'c' in the |= operation will be:
    // 00000000 00000000 00000000 00000001 (bits variable)
    // 00000000 00000000 00000000 00000100 (letter we received)
    // -----------------------------------
    // 00000000 00000000 00000000 00000101 (new bits value)
    // So you see that we start to mark with 1 for each letter of the alphabet we receive.
    // At the end we need to check if the bits variable equals to 26 ones (11111111 11111111 11111111 11111111) which in hex is 0x03FFFFFF
}
