# $Id$
#------------------------------------------------------------------
#
# BioPerl module Bio::Restriction::Enzyme
#
# Cared for by Rob Edwards <redwards@utmem.edu>
#
# You may distribute this module under the same terms as perl itself
#------------------------------------------------------------------

## POD Documentation:

=head1 NAME

Bio::Restriction::Enzyme - A single restriction endonuclease
(cuts DNA at specific locations)

=head1 SYNOPSIS

  # set up a single restriction enzyme. This contains lots of
  # information about the enzyme that is generally parsed from a
  # rebase file and can then be read back

  use Bio::Restriction::Enzyme;

  # define a new enzyme with the cut sequence
  my $re=new Bio::Restriction::Enzyme
      (-enzyme=>'EcoRI', -seq=>'G^AATTC');

  # once the sequence has been defined a bunch of stuff is calculated
  # for you:

  #### PRECALCULATED

  # find where the enzyme cuts after ...
  my $ca=$re->cut;

  # ... and where it cuts on the opposite strand
  my $oca = $re->complementary_cut;

  # get the cut sequence string back.
  # Note that site will return the sequence with a caret
  my $with_caret=$re->site; #returns 'G^AATTC';

  # but it is also a Bio::PrimarySeq object ....
  my $without_caret=$re->seq; # returns 'GAATTC';
  # ... and so does string
  $without_caret=$re->string; #returns 'GAATTC';

  # what is the reverse complement of the cut site
  my $rc=$re->revcom; # returns 'GAATTC';

  # now the recognition length. There are two types:
  #   recognition_length() is the length of the sequence
  #   cutter() estimate of cut frequency

  my $recog_length = $re->recognition_length; # returns 6
  # also returns 6 in this case but would return 
  # 4 for GANNTC and 5 for RGATCY (BstX2I)!
  $recog_length=$re->cutter; 

  # is the sequence a palindrome  - the same forwards and backwards
  my $pal= $re->palindromic; # this is a boolean

  # is the sequence blunt (i.e. no overhang - the forward and reverse
  # cuts are the same)
  print "blunt\n" if $re->overhang eq 'blunt';

  # Overhang can have three values: "5'", "3'", "blunt", and undef
  # Direction is very important if you use Klenow!
  my $oh=$re->overhang;

  # what is the overhang sequence
  my $ohseq=$re->overhang_seq; # will return 'AATT';

  # is the sequence ambiguous - does it contain non-GATC bases?
  my $ambig=$re->is_ambiguous; # this is boolean

  print "Stuff about the enzyme\nCuts after: $ca\n",
        "Complementary cut: $oca\nSite:\n\t$with_caret or\n",
        "\t$without_caret\n";
  print "Reverse of the sequence: $rc\nRecognition length: $recog_length\n",
        "Is it palindromic? $pal\nIs it blunt? $blunt\n";
  print "The overhang is $oh with sequence $ohseq\n",
        "And is it ambiguous? $ambig\n\n";


  ### THINGS YOU CAN SET, and get from rich REBASE file

  # get or set the isoschizomers (enzymes that recognize the same
  # site)
  $re->isoschizomers('PvuII', 'SmaI'); # not really true :)
  print "Isoschizomers are ", join " ", $re->isoschizomers, "\n";

  # get or set the methylation sites
  $re->methylation_sites(2); # not really true :)
  print "Methylated at ", join " ", keys $re->methylation_sites,"\n";

  #Get or set the source microbe
  $re->microbe('E. coli');
  print "It came from ", $re->microbe, "\n";

  # get or set the person who isolated it
  $re->source("Rob"); # not really true :)
  print $re->source, " sent it to us\n";

  # get or set whether it is commercially available and the company
  # that it can be bought at
  $re->vendors('NEB'); # my favorite
  print "Is it commercially available :";
  print $re->vendors ? "Yes" : "No";
  print " and it can be got from ", join " ", 
      $re->vendors, "\n";

  # get or set a reference for this
  $re->reference('Edwards et al. J. Bacteriology');
  print "It wasn't published in ", $re->reference, "\n";

  # get or set the enzyme name
  $re->name('BamHI');
  print "The name of EcoRI is not really ", $re->name, "\n";


=head1 DESCRIPTION

This module defines a single restriction endonuclease.  You can use it
to make custom restriction enzymes, and it is used by
Bio::Restriction::IO to define enzymes in the New England Biolabs
REBASE collection.

Use Bio::Restriction::Analysis to figure out which enzymes are available
and where they cut your sequence.


=head1 RESTRICTION MODIFICATION SYSTEMS

At least three geneticaly and biochamically distinct restriction
modification systems exist. The cutting components of them are known
as restriction endonuleases.  The three systems are known by roman
numerals: Type I, II, and III restriction enzymes.

REBASE format 'cutzymes'(#15) lists enzyme type in its last field. The
categories there do not always match the the following short
descriptions of the enzymes types. See
http://it.stlawu.edu/~tbudd/rmsyst.html for a better overview.


=head2 TypeI

Type I systems recognize a bipartite asymetrical sequence of 5-7 bp:

  ---TGA*NnTGCT--- * = methylation sites
  ---ACTNnA*CGA--- n = 6 for EcoK, n = 8 for EcoB

The cleavage site is roughly 1000 (400-7000) base pairs from the
recognition site.

=head2 TypeII

The simplest and most common (at least commercially).

Site recognition is via short palindromic base sequences that are 4-6
base pairs long. Cleavage is at the recognition site (but may
occasionally be just adjacent to the palindromic sequence, usually
within) and may produce blunt end termini or staggered, "sticky
end" termini.

=head2 TypeIII

The recognition site is a 5-7 bp asymmetrical sequence. Cleavage is
ATP dependent 24-26 base pairs downstream from the recognition site
and usually yields staggered cuts 2-4 bases apart.


=head1 COMMENTS

I am trying to make this backwards compatible with
Bio::Tools::RestrictionEnzyme.  Undoubtedly some things will break,
but we can fix things as we progress.....!

I have added another comments section at the end of this POD that
discusses a couple of areas I know are broken (at the moment)


=head1 TO DO

=over 2

=item *

Convert vendors touse full names of companies instead of code

=item *

Add regular expression based matching to vendors

=back

=head1 COMMENTS ON COMPATIBILITY

These are things that are likely to break compatibility at the
moment. I am especially trying to make note of routines that are not
in this version of Restriction::Enzyme, versus those that are in the
old version. Note, some of these may be covered in the other modules
that I haven't written yet.

 1. _make_custom and _make_standard

Because I have removed the demand that the sequence be extant, these
are no longer applicable.  Everything is a custom enzyme.

=head1 FEEDBACK

=head2 Mailing Lists

User feedback is an integral part of the evolution of this and other
Bioperl modules. Send your comments and suggestions preferably to one
of the Bioperl mailing lists. Your participation is much appreciated.

   bioperl-l@bioperl.org              - General discussion
   http://bioperl.org/MailList.shtml  - About the mailing lists

=head2 Reporting Bugs

Report bugs to the Bioperl bug tracking system to help us keep track
the bugs and their resolution. Bug reports can be submitted via email
or the web:

    bioperl-bugs@bio.perl.org
    http://bugzilla.bioperl.org/

=head1 AUTHOR

Rob Edwards, redwards@utmem.edu

=head1 CONTRIBUTORS

Heikki Lehvaslaiho, heikki@ebi.ac.uk

=head1 COPYRIGHT

Copyright (c) 2003 Rob Edwards.

Some of this work is Copyright (c) 1997-2002 Steve A. Chervitz. All
Rights Reserved.  This module is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

=head1 SEE ALSO

L<Bio::Restriction::Analysis>, 
L<Bio::Restriction::EnzymeCollection>, L<Bio::Restriction::IO>

=head1 APPENDIX

Methods beginning with a leading underscore are considered private and
are intended for internal use by this module. They are not considered
part of the public interface and are described here for documentation
purposes only.

=cut

package Bio::Restriction::Enzyme;
use strict;

use Bio::Root::Root;
use Bio::PrimarySeq;
use Bio::Restriction::EnzymeI;
use Storable;

use Data::Dumper;

use vars qw (@ISA %TYPE );
@ISA = qw(Bio::Root::Root Bio::Restriction::EnzymeI);

BEGIN {
    my %TYPE = (I => 1, II => 1, III => 1);
}

=head2 new

 Title     : new
 Function
 Function  : Initializes the Enzyme object
 Returns   : The Restriction::Enzyme object
 Argument  : A standard definition can have several formats. For example:
	     $re->new(-enzyme='EcoRI', -seq->'GAATTC' -cut->'1')
             Or, you can define the cut site in the sequence, for example
	     $re->new(-enzyme='EcoRI', -seq->'G^AATTC'), but you must use a caret
	     Or, a sequence can cut outside the recognition site, for example
	     $re->new(-enzyme='AbeI', -seq->'CCTCAGC' -cut->'-5/-2')

	     Other arguments:
	     -isoschizomers=>\@list  a reference to an array of
              known isoschizomers
	     -references=>$ref a reference to the enzyme
	     -source=>$source the source (person) of the enzyme
	     -commercial_availability=>@companies a list of companies
              that supply the enzyme
	     -methylation_site=>\%sites a reference to hash that has
              the position as the key and the type of methylation
              as the value

A Restriction::Enzyme object manages its recognition sequence as a
Bio::PrimarySeq object.

The minimum requirement is for a name and a sequence.

This will create the restriction enzyme object, and define several
things about the sequence, such as palindromic, size, etc.

=cut

sub new {
    my($class, @args) = @_;
    my $self = $class->SUPER::new(@args);

    my ($name,$enzyme,$site,$cut,$complementary_cut, $is_prototype, $prototype,
        $isoschizomers, $meth, $microbe, $source, $vendors, $references) =
            $self->_rearrange([qw(
                                  NAME
                                  ENZYME
                                  SITE
                                  CUT
                                  COMPLEMENTARY_CUT
                                  IS_PROTOTYPE
                                  PROTOTYPE
                                  ISOSCHIZOMERS
                                  METHYLATION_SITES
                                  MICROBE
                                  SOURCE
                                  VENDORS
                                  REFERENCES
                                 )], @args);




    $self->{_isoschizomers} = ();
    $self->{_methylation_sites} = {};
    $self->{_vendors} = ();
    $self->{_references} = ();

    $name && $self->name($name);
    $enzyme && $self->name($enzyme);
    $site && $self->site($site);
    $self->throw('At the minimum, you must define a name and '.
                 'recognition site for the restriction enzyme')
        unless $self->{'_name'} && $self->{'_seq'};


    $cut && $self->cut($cut);
    $complementary_cut && $self->complementary_cut($complementary_cut);
    $is_prototype && $self->is_prototype($is_prototype);
    $prototype && $self->prototype($prototype);
    $isoschizomers && $self->isoschizomers($isoschizomers);
    $meth && $self->methylation_sites($meth);
    $microbe && $self->microbe($microbe);
    $source && $self->source($source);
    $vendors && $self->vendors($vendors);
    $references && $self->references($references);

    return $self;
}

=head2 Essential methods

=cut

=head2 name

 Title    : name
 Usage    : $re->name($newval)
 Function : Gets/Sets the restriction enzyme name
 Example  : $re->name('EcoRI')
 Returns  : value of name
 Args     : newvalue (optional)

This will also clean up the name. I have added this because some
people get confused about restriction enzyme names.  The name should
be One upper case letter, and two lower case letters (because it is
derived from the organism name, eg.  EcoRI is from E. coli). After
that it is all confused, but the numbers should be roman numbers not
numbers, therefore we'll correct those. At least this will provide
some standard, I hope.

=cut

sub name{
    my ($self, $name)=@_;

    if ($name) {                # correct and set the name
        my $old_name = $name;

        # remove spaces. Some people write HindIII as Hind III
        $name =~ s/\s+//g;
        # change TAILING ones to I's
        if ($name =~ m/(1+)$/) {
            my $i = 'I' x length($1);
            $name =~ s/1+$/$i/;
        }

        # make the first letter upper case
        $name =~ s/^(\w)/uc($1)/e;

        unless ($name eq $old_name) {
            # we have changed the name, so send a warning
            $self->warn("The enzyme name $old_name was changed to $name");
        }
        $self->{'_name'} = $name;
    }
    return $self->{'_name'};
}


=head2 site

 Title     : site
 Usage     : $re->site();
 Function  : Gets/sets the recognition sequence for the enzyme.
 Example   : $seq_string = $re->site();
 Returns   : String containing recognition sequence indicating
           : cleavage site as in  'G^AATTC'.
 Argument  : n/a
 Throws    : n/a


Side effect: the sequence is always converted to upper case.

The cut site can also be set by using methods L<cut|cut> and
L<complementary_cut|complementary_cut>.

This will pad out missing sequence with N's. For example the enzyme
Acc36I cuts at ACCTGC(4/8). This will be returned as ACCTGCNNNN^

Note that the common notation ACCTGC(4/8) means that the forward
strand cut is four nucleotides after the END of the recognition
site. The forwad cut() in the coordinates used here in Acc36I
ACCTGC(4/8) is at 6+4 i.e. 10.

** This is the main setable method for the recognition site.

=cut

sub site {
    my ($self, $site) = @_;
    if ( $site ) {

        $self->throw("Unrecognized characters in site: [$site]")
            unless $site =~ /[ATGCMRWSYKVHDBN\^]+/i;
        # we may have to redefine this if there is a ^ in the sequence

        # first, check and see if we have a cut site in the sequence
        # if so, find the position, and set the target sequence and cut site

        $self->{'_site'} = $site;

        my ($first, $second) = $site =~ /(.*)\^(.*)/;
        $site = "$1$2" if defined $first;
        $self->{'_site'} = $site;


        # now set the recognition site as a new Bio::PrimarySeq object
        # we need it before caling cut() and complementary_cut()
        $self->{_seq} = new Bio::PrimarySeq(-id=>$self->name,
                                            -seq=>$site,
                                            -verbose=>$self->verbose,
                                            -alphabet=>'dna');

        if (defined $first) {
            $self->cut(length $first);
            $self->complementary_cut(length $second);
        }
    }
    return $self->{'_site'};
}


=head2 cut

 Title     : cut
 Usage     : $num = $re->cut(1);
 Function  : Sets/gets an integer indicating the position of cleavage
             relative to the 5' end of the recognition sequence in the
             forward strand.

             For type II enzymes, sets the symmetrically positioned
             reverse strand cut site by calling complementary_cut().

 Returns   : Integer, 0 if not set
 Argument  : an integer for the forward strand cut site (optional)

Note that the common notation ACCTGC(4/8) means that the forward
strand cut is four nucleotides after the END of the recognition
site. The forwad cut in the coordinates used here in Acc36I
ACCTGC(4/8) is at 6+4 i.e. 10.

Note that REBASE uses notation where cuts within symmetic sites are
marked by '^' within the forward sequence but if the site is
asymmetric the parenthesis syntax is used where numbering ALWAYS
starts from last nucleotide in the forward strand. That's why AciI has
a site usually written as CCGC(-3/-1) actualy cuts in

  C^C G C
  G G C^G

In our notation, these locations are 1 and 3.


The cuts locations in the notation used are relative to the first
(non-N) nucleotide of the reported forward strand of the recognition
sequence. The following diagram numbers the phosphodiester bonds
(marked by + ) which can be cut by the restriction enzymes:

                           1   2   3   4   5   6   7   8  ...
     N + N + N + N + N + G + A + C + T + G + G + N + N + N
  ... -5  -4  -3  -2  -1


=cut

sub cuts_after {
    shift->cut(@_);
}

sub cut {
     my ($self, $value) = @_;
     if (defined $value) {
         $self->throw("The cut position needs to be an integer [$value]")
             unless $value =~ /[-+]?\d+/;
         $self->{'_cut'} = $value;
         if ($value == 0) {
             $self->{'_site'} =~ s/\^//;
             return $self->complementary_cut(0);
         }
         $self->complementary_cut(length ($self->seq->seq) - $value )
             if $self->type eq 'II';

         if (length ($self->{_site}) < $value ) {
             my $pad_length = $value - length $self->{_site};
             $self->{_site} .= 'N' x $pad_length;
         }
         $self->{_site} =
             substr($self->{_site}, 0, $value). '^'. substr($self->{_site}, $value)
                 unless $self->{_site} =~ /\^/;
     }
     return $self->{'_cut'} || 0;
}



=head2 complementary_cut

 Title     : complementary_cut
 Usage     : $num = $re->complementary_cut('1');
 Function  : Sets/Gets an integer indicating the position of cleavage
           : on the reverse strand of the restriction site.
 Returns   : Integer
 Argument  : An integer (optional)
 Throws    : Exception if argument is non-numeric.

This method determines the cut on the reverse strand of the sequence.
For most enzymes this will be within the sequence, and will be set
automatically based on the forward strand cut, but it need not be.

B<Note> that the returned location indicates the location AFTER the
first non-N site nucleotide in the FORWARD strand.

=cut

sub complementary_cut {
    my ($self, $num)=@_;

    if (defined $num) {
        $self->throw("The cut position needs to be an integer [$num]")
            unless $num =~ /[-+]?\d+/;
        $self->{'_rc_cut'} = $num;
    }
    return $self->{'_rc_cut'} || 0;
}


=head2 Read only (usually) recognition site descriptive methods

=cut

=head2 type

 Title     : type
 Usage     : $re->type();
 Function  : Get/set the restriction system type
 Returns   : 
 Argument  : optional type: ('I'|II|III)

Restriction enzymes have been catezorized into three types. Some
REBASE formats give the type, but the following rules can be used to
classify the known enzymes:

=over 4

=item 1

Bipartite site (with 6-8 Ns in the middle and the cut site
is E<gt> 50 nt away) =E<gt> type I

=item 2

Site length E<lt> 3  =E<gt> type I

=item 3

5-6 asymmetric site and cuts E<gt>20 nt away =E<gt> type III

=item 4

All other  =E<gt> type II

=back

There are some enzymes in REBASE which have bipartite recognition site
and cat far from the site but are still classified as type I. I've no
idea if this is really so.

=cut

sub type {
    my ($self, $value) = @_;

    if ($value) {
        $self->throw("Not a valid value [$value], needs to one of : ".
                     join (', ', sort keys %TYPE) ) 
            unless $TYPE{$value};
        return $self->{'_type'} = $value;
    }

    # pre set
    #return $self->{'_type'} if $self->{'_type'};
    # bipartite
    return $self->{'_type'} = 'I'
        if $self->{'_seq'}->seq =~ /N*[^N]+N{6,8}[^N]/ and abs($self->cut) > 50 ;
    # 3 nt site
    return $self->{'_type'} = 'I'
        if $self->{'_seq'}->length == 3;
    # asymmetric and cuts > 20 nt
    return $self->{'_type'} = 'III'
        if (length $self->string == 5 or length $self->string == 6 ) and
            not $self->palindromic and abs($self->cut) > 20;
    return $self->{'_type'} = 'II';
}

=head2 seq

 Title     : seq
 Usage     : $re->seq();
 Function  : Get the Bio::PrimarySeq.pm object representing
           : the recognition sequence
 Returns   : A Bio::PrimarySeq object representing the
             enzyme recognition site
 Argument  : n/a
 Throws    : n/a


=cut

sub seq {
    shift->{'_seq'};
}

=head2 string

 Title     : string
 Usage     : $re->string();
 Function  : Get a string representing the recognition sequence.
 Returns   : String. Does NOT contain a  '^' representing the cut location
             as returned by the site() method.
 Argument  : n/a
 Throws    : n/a

=cut

sub string {
    shift->{'_seq'}->seq;
}



=head2 revcom

 Title     : revcom
 Usage     : $re->revcom();
 Function  : Get a string representing the reverse complement of
           : the recognition sequence.
 Returns   : String
 Argument  : n/a
 Throws    : n/a

=cut

sub revcom {
    shift->{'_seq'}->revcom->seq();
}

=head2 recognition_length

 Title     : recognition_length
 Usage     : $re->recognition_length();
 Function  : Get the length of the RECOGNITION sequence.
             This is the total recognition sequence,
             inluding the ambiguous codes.
 Returns   : An integer
 Argument  : Nothing

See also: L<non_ambiguous_length>

=cut

sub recognition_length {
    my $self = shift;
    return length($self->string);
}

=head2 cutter

 Title    : cutter
 Usage    : $re->cutter
 Function : Returns the "cutter" value of the recognition site.

            This is a value relative to site length and lack of
            ambiguity codes. Hence: 'RCATGY' is a five (5) cutter site
            and 'CCTNAGG' a six cutter

            This measure correlates to the frequency of the enzyme
            cuts much better than plain recognition site length.

 Example  : $re->cutter
 Returns  : integer or float number
 Args     : none



Why is this better than just stripping the ambiguos codes? Think about
it like this: You have a random sequence; all nucleotides are equally
probable. You have a four nucleotide re site. The probability of that
site finding a match is one out of 4^4 or 256, meaning that on average
a four cutter finds a match every 256 nucleotides. For a six cutter,
the average fragment length is 4^6 or 4096. In the case of ambiguity
codes the chances are finding the match are better: an R (A|T) has 1/2
chance of finding a match in a random sequence. Therefore, for RGCGCY
the probability is one out of (2*4*4*4*4*2) which exactly the same as
for a five cutter! Cutter, although it can have non-integer values
turns out to be a useful and simple measure.

=cut

sub cutter {
    my ($self)=@_;
    $_ = uc $self->string;

    my $cutter = tr/[ATGC]//d;
    my $count =  tr/[MRWSYK]//d;
    $cutter += $count/2;
    $count =  tr/[VHDB]//d;
    $cutter += $count*3/4;
    return $cutter;
}

=cut


=head2 palindromic

 Title     : palindromic
 Usage     : $re->palindromic();
 Function  : Determines if the recognition sequence is palindromic
           : for the current restriction enzyme.
 Returns   : Boolean
 Argument  : n/a
 Throws    : n/a

A palindromic site (EcoRI):

  5-GAATTC-3
  3-CTTAAG-5


=cut

sub palindromic {
    my $self = shift;
    if ($self->string eq $self->revcom) {
        $self->{_palindromic}=1;
    }
    return $self->{_palindromic} || 0;
}



=head2 overhang

 Title     : overhang
 Usage     : $re->overhang();
 Function  : Determines the overhang of the restriction enzyme
 Returns   : "5'", "3'", "blunt" of undef
 Argument  : n/a
 Throws    : n/a

A blunt site in SmaI returns C<blunt>

  5' C C C^G G G 3'
  3' G G G^C C C 5'

A 5' overhang in EcoRI returns C<5'>

  5' G^A A T T C 3'
  3' C T T A A^G 5'

A 3' overhang in KpnI returns C<3'>

  5' G G T A C^C 3'
  3' C^C A T G G 5'

=cut

sub overhang {
    my $self = shift;
    unless ($self->{'_cut'} && $self->{'_rc_cut'}) {
        return "unknown";
    }
    if ($self->{_cut} < $self->{_rc_cut}) {
        $self->{_overhang}="5'";
    } elsif ($self->{_cut} == $self->{_rc_cut}) {
        $self->{_overhang}="blunt";
    } elsif ($self->{_cut} > $self->{_rc_cut}) {
        $self->{_overhang}="3'";
    } else {
        $self->{_overhang}="unknown";
    }
    return $self->{_overhang}
}

=head2 overhang_seq

 Title     : overhang_seq
 Usage     : $re->overhang_seq();
 Function  : Determines the overhang sequence of the restriction enzyme
 Returns   : a Bio::LocatableSeq
 Argument  : n/a
 Throws    : n/a

I do not think it is necessary to create a seq object of these. (Heikki)

Note: returns empty string for blunt sequences and undef for ones that
we don't know.  Compare these:

A blunt site in SmaI returns empty string

  5' C C C^G G G 3'
  3' G G G^C C C 5'

A 5' overhang in EcoRI returns C<AATT>

  5' G^A A T T C 3'
  3' C T T A A^G 5'

A 3' overhang in KpnI returns C<GTAC>

  5' G G T A C^C 3'
  3' C^C A T G G 5'

Note that you need to use method L<overhang|overhang> to decide
whether it is a 5' or 3' overhang!!!

Note: The overhang stuff does not work if the site is asymmetric! Rethink! 

=cut

sub overhang_seq {
    my $self = shift;

#    my $overhang->Bio::PrimarySeq(-id=>$self->name . '-overhang',
#                                  -verbose=>$self->verbose,
#                                  -alphabet=>'dna');

    return '' if $self->overhang eq 'blunt' ;

    unless ($self->{_cut} && $self->{_rc_cut}) {
        # lets just check that we really can't figure it out
        $self->cut;
        $self->complementary_cut;
        unless ($self->{_cut} && $self->{_rc_cut}) {
            return;
        }
    }

    # this is throwing an error for sequences outside the restriction
    # site (eg ^NNNNGATCNNNN^)
    # So if this is the case we need to fake these guys
    if (($self->{_cut}<0) ||
        ($self->{_rc_cut}<0) || 
        ($self->{_cut}>$self->seq->length) ||
        ($self->{_rc_cut}>$self->seq->length)) {
        my $tempseq=$self->site;
        my ($five, $three)=split /\^/, $tempseq;
        if ($self->{_cut} > $self->{_rc_cut}) {
            return substr($five, $self->{_rc_cut})
        } elsif ($self->{_cut} < $self->{_rc_cut}) {
            return substr($three, 0, $self->{_rc_cut})
        } else {
            return '';
        }
    }

    if ($self->{_cut} > $self->{_rc_cut}) {
        return $self->seq->subseq($self->{_rc_cut}+1,$self->{_cut});
    } elsif ($self->{_cut} < $self->{_rc_cut}) {
        return $self->seq->subseq($self->{_cut}+1, $self->{_rc_cut});
    } else {
        return '';
    }
}



=head2 compatible_ends

 Title     : compatible_ends
 Usage     : $re->compatible_ends($re2);
 Function  : Determines if the two restriction enzyme cut sites
              have compatible ends.
 Returns   : 0 if not, 1 if only one pair ends match, 2 if both ends.
 Argument  : a Bio::Restriction::Enzyme
 Throws    : unless the argument is a Bio::Resriction::Enzyme and
             if there are Ns in the ovarhangs

In case of type II enzymes which which cut symmetrically, this
function can be considered to return a boolean value.


=cut

sub compatible_ends {
    my ($self, $re) = @_;

    $self->throw("Need a Bio::Restriction::Enzyme as an argument, [$re]")
        unless $re->isa('Bio::Restriction::Enzyme');

#    $self->throw("Only type II enzymes work now")
#        unless $self->type eq 'II';

    $self->debug("N(s) in overhangs. Can not compare")
        if $self->overhang_seq =~ /N/ or $re->overhang_seq =~ /N/;

    return 2 if $self->overhang_seq eq $re->overhang_seq and
        $self->overhang eq $re->overhang;

    return 0;
}

=head2 is_ambiguous

 Title     : is_ambiguous
 Usage     : $re->is_ambiguous();
 Function  : Determines if the restriction enzyme contains ambiguous sequences
 Returns   : Boolean
 Argument  : n/a
 Throws    : n/a

=cut

sub is_ambiguous {
    my $self = shift;
    return $self->string =~ m/[^AGCT]/ ? 1 : 0 ;
}

=head2 Additional methods from Rebase

=cut


=head2 is_prototype

 Title    : is_prototype
 Usage    : $re->is_prototype
 Function : Get/Set method for finding out if this enzyme is a prototype
 Example  : $re->is_prototype(1)
 Returns  : Boolean
 Args     : none

Prototype enzymes are the most commonly available and usually first
enzymes discoverd that have the same recognition site. Using only
prototype enzymes in restriciton analysis avoids redundacy and
speeds things up.

=cut

sub is_prototype {
     my $self = shift;
     if (@_) {
         (shift) ? (return $self->{'_is_prototype'} = 1) :
                   (return $self->{'_is_prototype'} = 0) ;
     }
     return $self->{'_is_prototype'} || 0;
}

=head2 prototype_name

 Title    : prototype_name
 Usage    : $re->prototype_name
 Function : Get/Set method for the name of prototype for
            this enzyme's recognition site
 Example  : $re->prototype_name(1)
 Returns  : prototype enzyme name string or an empty string
 Args     : optional prototype enzyme name string

If the enzyme itself is the protype, its own name is returned.  Not to
confuse the negative result with an unset value, use method
L<is_prototype|is_prototype>.

This method is called I<prototype_name> rather than I<prototype>,
because it returns a string rather than on object.

=cut

sub prototype_name {
     my $self = shift;

     $self->{'_prototype'} = shift if @_;
     return $self->name if $self->{'_is_prototype'};
     return $self->{'_prototype'} || '';
}

=head2 isoschizomers

 Title     : isoschizomers
 Usage     : $re->isoschizomers(@list);
 Function  : Gets/Sets a list of known isoschizomers (enzymes that
             recognize the same site, but don't necessarily cut at
             the same position).
 Arguments : A reference to an array that contains the isoschizomers
 Returns   : A reference to an array of the known isoschizomers or 0
             if not defined.

This has to be the hardest name to spell.  Added for compatibility to
REBASE

=cut


sub isoschizomers {
    my ($self) = shift;
    push @{$self->{_isoschizomers}}, @_ if @_;
    return @{$self->{_isoschizomers}};
}


=head2 purge_isoschizomers

 Title     : purge_isoschizomers
 Usage     : $re->purge_isoschizomers();
 Function  : Purges the set of isoschizomers for this enzyme
 Arguments : 
 Returns   : 1

=cut

sub purge_isoschizomers {
    my ($self) = shift;
    $self->{_isoschizomers} = [];

}


=head2 methylation_sites

 Title     : methylation_sites
 Usage     : $re->methylation_sites(\%sites);
 Function  : Gets/Sets known methylation sites (positions on the sequence
             that get modified to promote or prevent cleavage).
 Arguments : A reference to a hash that contains the methylation sites
 Returns   : A reference to a hash of the methylation sites or
             an empty string if not defined.

There are three types of methylation sites:

=over 3

=item *  (6) = N6-methyladenosine

=item *  (5) = 5-methylcytosine

=item *  (4) = N4-methylcytosine

=back

These are stored as 6, 5, and 4 respectively.  The hash has the
sequence position as the key and the type of methylation as the value.
A negative number in the sequence position indicates that the DNA is
methylated on the complementary strand.

Note that in REBASE, the methylation positions are given 
Added for compatibility to REBASE.

=cut

sub methylation_sites {
    my $self = shift;

    while (@_) {
        my $key = shift;
        $self->{'_methylation_sites'}->{$key} = shift;
    }
    return %{$self->{_methylation_sites}};
}


=head2 purge_methylation_sites

 Title     : purge_methylation_sites
 Usage     : $re->purge_methylation_sites();
 Function  : Purges the set of methylation_sites for this enzyme
 Arguments : 
 Returns   : 

=cut

sub purge_methylation_sites {
    my ($self) = shift;
    $self->{_methylation_sites} = {};
}

=head2 microbe

 Title     : microbe
 Usage     : $re->microbe($microbe);
 Function  : Gets/Sets microorganism where the restriction enzyme was found
 Arguments : A scalar containing the microbes name
 Returns   : A scalar containing the microbes name or 0 if not defined

Added for compatibility to REBASE

=cut

sub microbe {
    my ($self, $microbe) = @_;
    if ($microbe) {
        $self->{_microbe}=$microbe;
    }
    return $self->{_microbe} || '';

}


=head2 source

 Title     : source
 Usage     : $re->source('Rob Edwards');
 Function  : Gets/Sets the person who provided the enzyme
 Arguments : A scalar containing the persons name
 Returns   : A scalar containing the persons name or 0 if not defined

Added for compatibility to REBASE

=cut

sub source {
    my ($self, $source) = @_;
    if ($source) {
        $self->{_source}=$source;
    }
    return $self->{_source} || '';
}


=head2 vendors

 Title     : vendors
 Usage     : $re->vendor(@list_of_companies);
 Function  : Gets/Sets the a list of companies that you can get the enzyme from.
             Also sets the commercially_available boolean
 Arguments : A reference to an array containing the names of companies
             that you can get the enzyme from
 Returns   : A reference to an array containing the names of companies
             that you can get the enzyme from

Added for compatibility to REBASE

=cut

sub vendors {
    my $self = shift;
    push @{$self->{_vendors}}, @_ if @_;
    return @{$self->{'_vendors'}};
}


=head2 purge_vendors

 Title     : purge_vendors
 Usage     : $re->purge_references();
 Function  : Purges the set of references for this enzyme
 Arguments : 
 Returns   : 

=cut

sub purge_vendors {
    my ($self) = shift;
    $self->{_vendors} = [];

}

=head2 vendor

 Title     : vendor
 Usage     : $re->vendor(@list_of_companies);
 Function  : Gets/Sets the a list of companies that you can get the enzyme from.
             Also sets the commercially_available boolean
 Arguments : A reference to an array containing the names of companies
             that you can get the enzyme from
 Returns   : A reference to an array containing the names of companies
             that you can get the enzyme from

Added for compatibility to REBASE

=cut


sub vendor {
    my $self = shift;
    return push @{$self->{_vendors}}, @_;
    return $self->{_vendors};
}


=head2 references

 Title     : references
 Usage     : $re->references(string);
 Function  : Gets/Sets the references for this enzyme
 Arguments : an array of string reference(s) (optional)
 Returns   : an array of references

Use L<purge_references|purge_references> to reset the list of references

This should be a L<Bio::Biblio> object, but its not (yet)

=cut

sub references {
    my ($self) = shift;
    push @{$self->{_references}}, @_ if @_;
    return @{$self->{_references}};
}


=head2 purge_references

 Title     : purge_references
 Usage     : $re->purge_references();
 Function  : Purges the set of references for this enzyme
 Arguments : 
 Returns   : 1

=cut

sub purge_references {
    my ($self) = shift;
    $self->{_references} = [];

}




=head2 clone

 Title     : clone
 Usage     : $re->clone
 Function  : Deep clone the object
 Arguments : -
 Returns   : new Bio::Restriction::EnzymeI object

=cut

sub clone {
    my ($self) = shift;
    return Storable::dclone($self);
}




1;

