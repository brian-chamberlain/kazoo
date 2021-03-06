%%%-------------------------------------------------------------------
%%% @copyright (C) 2017, 2600Hz INC
%%% @doc
%%%
%%% Ratedeck document accessors
%%%   Every account can be assigned a ratedeck
%%%
%%% @end
%%% @contributors
%%%   James Aimonetti
%%%-------------------------------------------------------------------
-module(kzd_ratedeck).

-export([id/0
        ,name/1
        ,database_name/1
        ,format_ratedeck_db/1
        ,format_ratedeck_id/1
        ]).

-include("kz_documents.hrl").
-include_lib("kazoo_documents/include/kzd_ratedeck.hrl").

-type doc() :: kz_json:object().
-export_type([doc/0]).

-spec id() -> ne_binary().
id() -> <<"ratedeck">>.

-spec name(doc()) -> api_ne_binary().
name(Doc) ->
    kz_json:get_ne_binary_value(<<"name">>, Doc).

-spec database_name(doc()) -> api_ne_binary().
database_name(Doc) ->
    case name(Doc) of
        'undefined' -> ?KZ_RATES_DB;
        Name -> format_ratedeck_db(Name)
    end.

-spec format_ratedeck_db(ne_binary()) -> ne_binary().
format_ratedeck_db(?KZ_RATES_DB) -> ?KZ_RATES_DB;
format_ratedeck_db(?MATCH_RATEDECK_DB_ENCODED(_)=Db) -> Db;
format_ratedeck_db(?MATCH_RATEDECK_DB_encoded(_)=Db) -> Db;
format_ratedeck_db(?MATCH_RATEDECK_DB_UNENCODED(RatedeckId)) -> ?ENCODE_RATEDECK_DB(RatedeckId);
format_ratedeck_db(<<_/binary>> = RatedeckId) ->
    ?ENCODE_RATEDECK_DB(RatedeckId).

-spec format_ratedeck_id(ne_binary()) -> ne_binary().
format_ratedeck_id(?KZ_RATES_DB) -> ?KZ_RATES_DB;
format_ratedeck_id(?MATCH_RATEDECK_DB_ENCODED(Id)) -> Id;
format_ratedeck_id(?MATCH_RATEDECK_DB_encoded(Id)) -> Id;
format_ratedeck_id(?MATCH_RATEDECK_DB_UNENCODED(Id)) -> Id;
format_ratedeck_id(<<_/binary>> = Id) -> Id.
