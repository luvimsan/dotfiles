require("luasnip.session.snippet_collection").clear_snippets("cpp")

local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt

ls.add_snippets("cpp", {
	s(
		"main",
		fmt(
			[[
#include <iostream>

int main() {{
    {}
    return 0;
}}
]],
			{
				i(0),
			}
		)
	),

	s("cp", {
		t({
			"// Problem: ",
		}),
		t({
			"",
			"// Author: luvimsan",
			"// Created: " .. os.date("%a %d %b %Y %H:%M"),
			"// .____     ____ _______   ____.___   _____    _________   _____    _______   ",
			"// |    |   |    |   \\   \\ /   /|   | /     \\  /   _____/  /  _  \\   \\      \\  ",
			"// |    |   |    |   /\\   Y   / |   |/  \\ /  \\ \\_____  \\  /  /_\\  \\  /   |   \\ ",
			"// |    |___|    |  /  \\     /  |   /    Y    \\/        \\/    |    \\/    |    \\ ",
			"// |_______ \\______/    \\___/   |___\\____|__  /_______  /\\____|__  /\\____|__  /",
			"//         \\/                               \\/        \\/         \\/         \\/",
			"#include <iostream>",
			"#include <algorithm>",
			"#include <map>",
			"#include <set>",
			"#include <vector>",
			"",
			"using namespace std;",
			"typedef long long ll;",
			"typedef long double ld;",
			"",
			"#define vi vector<ll>",
			"#define all(v) v.begin(), v.end()",
			'#define el "\\n"',
			"",
			"void solve() {",
			"",
		}),
		i(1, ""),
		t({
			"",
			"}",
			"int main() {",
			"    ios_base::sync_with_stdio(false);",
			"    cin.tie(NULL);",
			"",
			"    ll tt = 1;",
			"    // cin >> tt;",
			"    while (tt--) {",
			"      solve();",
			"    }",
			"    return 0;",
			"}",
		}),
	}),
})
