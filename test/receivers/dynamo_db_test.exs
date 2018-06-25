defmodule Receivers.DynamoDBTest do
  use ExUnit.Case

  alias POABackend.Receivers.DynamoDB
  alias POABackend.Protocol.Message

  import Mock

  test "testing DynamoDB" do

    caller = self()

    with_mock ExAws, [
        request!: fn(%ExAws.Operation.JSON{data: %{"Item" => stored_block}}) ->
          send(caller, stored_block)
          :ok
        end
      ] do
      state = %{name: :dynamodb_receiver, args: args(), subscribe_to: [:ethereum_metrics]}

      {:ok, _} = DynamoDB.start_link(state)

      POABackend.Metric.add(:ethereum_metrics, valid_message())

      assert_receive stored_block, 20_000   

      {_, stored_block} = Map.pop(stored_block, "msg_time")

      assert stored_block == stored_block()
    end
  end

  defp args do
    [
      scheme: "http://",
      host: "localhost",
      port: 8000,
      access_key_id: "myaccesskey",
      secret_access_key: "mysecretaccesskey",
      region: "us-east-1"
    ]
  end

  defp valid_message do
    %Message{
      agent_id: "elixirNodeJSIntegration",
      assigns: %{},
      data: %{"body" => 
              %{"author" => "0x6e50b3d7a292380b3080022015b941f912ed62e9",
                "difficulty" => "340282366920938463463374607431768211454",
                "extra_data" => "0xd583010a008650617269747986312e32342e31826c69",
                "gas_limit" => 8_000_000,
                "gas_used" => 0,
                "hash" => "0x495054f5be069321c8bd394884ab0925e53dcd4734978e618106f05276ccfbe0",
                "miner" => "0x6e50b3d7a292380b3080022015b941f912ed62e9",
                "number" => 644_964,
                "parent_hash" => "0xd9197468f891bdee90aee83d15eb274dfb42de294af2d7fc78d652033e4ef27f",
                "receipts_root" => "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421",
                "seal_fields" => ["0x84123c0799", "0xb84174457964f4d98af28faec6f9c1f4eec928fc527d4cd884ef36031a064aafdd494ed5963c0e756166e88fda4491cfc99984a5924230fa3ace4e135e1578a1cb9000"],
                "sha3_uncles" => "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347",
                "signature" => "74457964f4d98af28faec6f9c1f4eec928fc527d4cd884ef36031a064aafdd494ed5963c0e756166e88fda4491cfc99984a5924230fa3ace4e135e1578a1cb9000",
                "size" => 579,
                "state_root" => "0x4b6d81e4060fdbc88197440d0ce1a2d0ec0f730698b7226a72ca256073508aee",
                "step" => "305923993",
                "timestamp" => 1_529_619_965,
                "total_difficulty" => "219469876498796155149191940307622952427069699",
                "transactions" => [],
                "transactions_root" =>"0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421",
                "uncles" => []},
                "type" => "block"},
      data_type: :ethereum_metrics,
      message_type: :data
    }
  end

  defp stored_block do
    %{
       "msg_type" => %{"S" => "block"},
       "payload" => %{"M" => %{
          "block" => %{
            "M" => %{
              "author" => %{"S" => "0x6e50b3d7a292380b3080022015b941f912ed62e9"},
              "difficulty" => %{"S" => "340282366920938463463374607431768211454"},
              "extra_data" => %{"S" => "0xd583010a008650617269747986312e32342e31826c69"},
              "gas_limit" => %{"N" => "8000000"},
              "gas_used" => %{"N" => "0"},
              "hash" => %{"S" => "0x495054f5be069321c8bd394884ab0925e53dcd4734978e618106f05276ccfbe0"},
              "miner" => %{"S" => "0x6e50b3d7a292380b3080022015b941f912ed62e9"},
              "number" => %{"N" => "644964"},
              "parent_hash" => %{"S" => "0xd9197468f891bdee90aee83d15eb274dfb42de294af2d7fc78d652033e4ef27f"},
              "receipts_root" => %{"S" => "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421"},
              "seal_fields" => %{"L" => [%{"S" => "0x84123c0799"}, %{"S" => "0xb84174457964f4d98af28faec6f9c1f4eec928fc527d4cd884ef36031a064aafdd494ed5963c0e756166e88fda4491cfc99984a5924230fa3ace4e135e1578a1cb9000"}]},
              "sha3_uncles" => %{"S" => "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347"},
              "signature" => %{"S" => "74457964f4d98af28faec6f9c1f4eec928fc527d4cd884ef36031a064aafdd494ed5963c0e756166e88fda4491cfc99984a5924230fa3ace4e135e1578a1cb9000"},
              "size" => %{"N" => "579"},
              "state_root" => %{"S" => "0x4b6d81e4060fdbc88197440d0ce1a2d0ec0f730698b7226a72ca256073508aee"},
              "step" => %{"S" => "305923993"},
              "timestamp" => %{"N" => "1529619965"},
              "total_difficulty" => %{"S" => "219469876498796155149191940307622952427069699"},
              "transactions_root" => %{"S" => "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421"}
              }
          }
        }
      }
    }
  end
  
end