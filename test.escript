#!/usr/bin/env escript

-include_lib("eunit/include/eunit.hrl").

main([]) ->
  code:add_path("ebin"),
  Tests = lists:append([signature_base_string_tests(), plaintext_tests(), hmac_sha1_tests(), rsa_sha1_tests()]),
  halt(case eunit:test(Tests) of ok -> 0; {error, _} -> 1 end).

signature_base_string_tests() ->
  test_with("base_string_test_*", [method, url, params, base_string], fun (Method, URL, Params, BaseString) ->
    [?_assertEqual(BaseString, oauth:signature_base_string(Method, URL, Params))]
  end).

plaintext_tests() ->
  test_with("plaintext_test_*", [consumer, token_secret, signature], fun (Consumer, TokenSecret, Signature) ->
    SignatureTest = ?_assertEqual(Signature, oauth:plaintext_signature(Consumer, TokenSecret)),
    VerifyTest = ?_assertEqual(true, oauth:plaintext_verify(Signature, Consumer, TokenSecret)),
    [SignatureTest, VerifyTest]
  end).

hmac_sha1_tests() ->
  test_with("hmac_sha1_test_*", [base_string, consumer, token_secret, signature], fun (BaseString, Consumer, TokenSecret, Signature) ->
    SignatureTest = ?_assertEqual(Signature, oauth:hmac_sha1_signature(BaseString, Consumer, TokenSecret)),
    VerifyTest = ?_assertEqual(true, oauth:hmac_sha1_verify(Signature, BaseString, Consumer, TokenSecret)),
    [SignatureTest, VerifyTest]
  end).

rsa_sha1_tests() ->
  Pkey = data_path("rsa_sha1_private_key.pem"),
  Cert = data_path("rsa_sha1_certificate.pem"),
  [BaseString, Signature] = read([base_string, signature], "rsa_sha1_test"),
  SignatureTest = ?_assertEqual(Signature, oauth:rsa_sha1_signature(BaseString, {"", Pkey, rsa_sha1})),
  VerifyTest = ?_assertEqual(true, oauth:rsa_sha1_verify(Signature, BaseString, {"", Cert, rsa_sha1})),
  [SignatureTest, VerifyTest].

test_with(FilenamePattern, Keys, Fun) ->
  lists:flatten(lists:map(fun (Path) -> apply(Fun, read(Keys, Path)) end, filelib:wildcard(data_path(FilenamePattern)))).

data_path(Basename) ->
  filename:join([filename:dirname(filename:absname(escript:script_name())), "testdata", Basename]).

read(Keys, Filename) ->
  {ok, Proplist} = file:consult(data_path(Filename)),
  [proplists:get_value(K, Proplist) || K <- Keys].
