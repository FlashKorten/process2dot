#!/usr/bin/env perl
use strict;
use warnings;

my $COMMENTS_IN_ENDSTATES = 0;
my $RENDER_EVENT_NAMES = 0;
my $SHOW_LABELS_OF_SINGLE_TRANSITIONS = 0;

my @action_nodes;
my @wait_nodes;
my @end_nodes;

$/ = undef;
my $input = <>;

$input =~ s/(^\s+|\s*[\n\r]\s*)//g;
$input =~ s/>\s+</></g;

foreach my $action_match ($input =~ /(<action.*?<\/action>)/g) {
    my @transitions;
    foreach my $transition_match ($action_match =~ /(<transition.*?\/>)/g) {
        push @transitions, {on => $transition_match =~ /name=["']([^"']+)["']/,
                            to => $transition_match =~ /to=["']([^"']+)["']/};
    }
    push @action_nodes, {action      => $action_match =~ /action.+?id=["']([^'"]+)["']/,
                         transitions => \@transitions};
}

foreach my $wait_match ($input =~ /(<wait.*?<\/wait>)/g) {
    my @transitions;
    my $event = $1 if $wait_match =~ /<event>(.*?)<\/event>/;
    if ($event) {
        my $event_name = $RENDER_EVENT_NAMES ? "Event: $event" : "Event";
        push @transitions, {on => $event_name,
                            to => $wait_match =~ /<wait.*?then=["']([^'"]+)["']/};
    }
    foreach my $timeout_match ($wait_match =~ /(<timeout.*?\/>)/g) {
        my $delay = $1 if $timeout_match =~ /delay=["']([^"']+)["']/;
        my $timeout_then = $1 if $timeout_match =~ /then=["']([^"']+)["']/;
        push @transitions, {on => "Timeout: $delay", to => $timeout_then};
    }
    push @wait_nodes, {action      => $wait_match =~ /<wait.*?id=["']([^'"]+)["']/,
                       transitions => \@transitions};
}

foreach my $end_match ($input =~ /(<end.*?<\/end>)/g) {
    my $end_id = $1 if $end_match =~ /\sid=["'](.+?)["']/;
    my $end_comment = $1 if $end_match =~ />(.+)<\/end>/;
    my $comment = $COMMENTS_IN_ENDSTATES ? " xlp = 0.0; xlabel = \"$end_comment\";" : "";
    push @end_nodes, "$end_id [label = \"$end_id\"; shape = parallelogram;$comment];";
}

my @dot_nodes;
my @dot_edges;

foreach my $action_ref (@action_nodes) {
    my $action_id = $$action_ref{'action'};
    my @transitions = @{$$action_ref{'transitions'}};
    foreach my $transition_ref (@transitions) {
        my $edge_def = "$action_id -> " . $$transition_ref{'to'};
        if ($SHOW_LABELS_OF_SINGLE_TRANSITIONS || @transitions > 1) {
            $edge_def .= " [ label = \"" . $$transition_ref{'on'} . "\" ];";
        }
        push @dot_edges, $edge_def;
    }
    my $shape = (@transitions == 1) ? "rect" : "diamond";
    push @dot_nodes, "$action_id [label = \"$action_id\"; shape = $shape;];";
}

foreach my $wait_ref (@wait_nodes) {
    my $wait_id = $$wait_ref{'action'};
    my @transitions = @{$$wait_ref{'transitions'}};
    foreach my $transition_ref (@transitions) {
        my $edge_def = "$wait_id -> " . $$transition_ref{'to'};
        if ($SHOW_LABELS_OF_SINGLE_TRANSITIONS || @transitions > 1) {
            $edge_def .= " [ label = \"" . $$transition_ref{'on'} . "\" ];";
        }
        push @dot_edges, $edge_def;
    }
    push @dot_nodes, "$wait_id [label = \"$wait_id\"; shape = oval;];";
}

push @dot_nodes, @end_nodes;

print "digraph G { node [fontname = \"Handlee\"]; edge [fontname = \"Handlee\"];\n";
foreach my $dot_node (@dot_nodes) { print "$dot_node\n"; }
foreach my $dot_edge (@dot_edges) { print "$dot_edge\n"; }
print "}\n";
