import Types "./Types";
import Result "mo:base/Result";
import Trie "mo:base/Trie";
import Principal "mo:base/Principal";
import Nat "mo:base/Nat";
import Time "mo:base/Time";
import List "mo:base/List";
import Iter "mo:base/Iter";
import Buffer "mo:base/Buffer";
import Debug "mo:base/Debug";
import HashMap "mo:base/HashMap";

actor {
  stable var next_proposal_id : Nat = 0;
  stable var proposals : [Types.Proposal] = [];
  stable var neuronEntries : [(Principal, Types.Neuron)] = [];

  let mb = actor("7igbu-3qaaa-aaaaa-qaapq-cai"): actor { mb: (Text) -> async Text };
  let neurons = HashMap.fromIter<Principal, Types.Neuron>(neuronEntries.vals(), Iter.size(neuronEntries.vals()), Principal.equal, Principal.hash);

  var proposal_buff = Buffer.fromArray<Types.Proposal>(proposals);

  func proposal_get(id : Nat) : Types.Proposal = proposal_buff.get(id);
  
  func proposal_put(proposal : Types.Proposal) {
    proposal_buff.add(proposal);
    proposals := Buffer.toArray(proposal_buff);
  };

  public shared ({ caller }) func submit_proposal(payload : Types.ProposalPayload) : async Types.Result<Nat, Text> {
    let proposal_id = next_proposal_id;
    next_proposal_id += 1;

    let proposal : Types.Proposal = {
      id = proposal_id;
      timestamp = Time.now();
      proposer = caller;
      payload;
      state = #open;
      votes_yes = Types.zeroToken;
      votes_no = Types.zeroToken;
      voters = List.nil()
    };

    proposal_put(proposal);
    return #ok(proposal_id);
  };

  public shared ({ caller }) func vote(proposal_id : Int, yes_or_no : Bool) : async Types.Result<(Nat, Nat), Text> {
    if(Principal.isAnonymous(caller)) {
      return #err("Anonymous caller");
    };

    let neuron = neurons.get(caller);
    var voting_power : Float = 0;

    // get MB token balance then vote.
    return #err("Not implemented yet")
  };

  public query func get_proposal(id : Nat) : async Types.Result<Types.Proposal, Text> {
    return #ok(proposal_buff.get(id));
  };

  public query func get_all_proposals() : async Types.Result<[Types.Proposal], Text> {
    return #ok(proposals);
  };

  system func preupgrade() {
    proposals := Buffer.toArray(proposal_buff);
  };

  system func postupgrade() {
    proposals := Buffer.toArray(proposal_buff);
  };
}
