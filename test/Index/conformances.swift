// RUN: %target-swift-ide-test -print-indexed-symbols -source-filename %s | %FileCheck %s

protocol P1 { // CHECK: [[@LINE]]:10 | protocol/Swift | P1 | [[P1_USR:.*]] | Def |
  func foo() // CHECK: [[@LINE]]:8 | instance-method/Swift | foo() | [[P1_foo_USR:.*]] | Def
}

struct DirectConf: P1 { // CHECK: [[@LINE]]:8 | struct/Swift | DirectConf | [[DirectConf_USR:.*]] | Def
  func foo() {} // CHECK: [[@LINE]]:8 | instance-method/Swift | foo() | [[DirectConf_foo_USR:.*]] | Def,RelChild,RelOver | rel: 2
    // CHECK-NEXT: RelOver | instance-method/Swift | foo() | [[P1_foo_USR]]
    // CHECK-NEXT: RelChild | struct/Swift | DirectConf | [[DirectConf_USR]]
}

struct ConfFromExtension {}
extension ConfFromExtension: P1 { // CHECK: [[@LINE]]:11 | extension/ext-struct/Swift | ConfFromExtension | [[ConfFromExtension_ext_USR:.*]] | Def
  func foo() {} // CHECK: [[@LINE]]:8 | instance-method/Swift | foo() | [[ConfFromExtension_ext_foo_USR:.*]] | Def,RelChild,RelOver | rel: 2
    // CHECK-NEXT: RelOver | instance-method/Swift | foo() | [[P1_foo_USR]]
    // CHECK-NEXT: RelChild | extension/ext-struct/Swift | ConfFromExtension | [[ConfFromExtension_ext_USR]]
}

struct ImplicitConfFromExtension { // CHECK: [[@LINE]]:8 | struct/Swift | ImplicitConfFromExtension | [[ImplicitConfFromExtension_USR:.*]] | Def
  func foo() {} // CHECK: [[@LINE]]:8 | instance-method/Swift | foo() | [[ImplicitConfFromExtension_foo_USR:.*]] | Def,RelChild | rel: 1
    // CHECK-NEXT: RelChild | struct/Swift | ImplicitConfFromExtension | [[ImplicitConfFromExtension_USR]]
}
extension ImplicitConfFromExtension: P1 { // CHECK: [[@LINE]]:11 | extension/ext-struct/Swift | ImplicitConfFromExtension | [[ImplicitConfFromExtension_USR:.*]] | Def
  // CHECK: [[@LINE-1]]:11 | instance-method/Swift | foo() | [[ImplicitConfFromExtension_foo_USR]] | Impl,RelOver,RelCont | rel: 2
  // CHECK-NEXT: RelOver | instance-method/Swift | foo() | [[P1_foo_USR]]
  // CHECK-NEXT: RelCont | extension/ext-struct/Swift | ImplicitConfFromExtension | [[ImplicitConfFromExtension_USR]]
}

class BaseConfFromBase { // CHECK: [[@LINE]]:7 | class/Swift | BaseConfFromBase | [[BaseConfFromBase_USR:.*]] | Def
  func foo() {} // CHECK: [[@LINE]]:8 | instance-method/Swift | foo() | [[BaseConfFromBase_foo_USR:.*]] | Def,Dyn,RelChild | rel: 1
    // CHECK-NEXT: RelChild | class/Swift | BaseConfFromBase | [[BaseConfFromBase_USR]]
}
class SubConfFromBase: BaseConfFromBase, P1 { // CHECK: [[@LINE]]:7 | class/Swift | SubConfFromBase | [[SubConfFromBase_USR:.*]] | Def
  // CHECK: [[@LINE-1]]:7 | instance-method/Swift | foo() | [[BaseConfFromBase_foo_USR]] | Impl,RelOver,RelCont | rel: 2
  // CHECK-NEXT: RelOver | instance-method/Swift | foo() | [[P1_foo_USR]]
  // CHECK-NEXT: RelCont | class/Swift | SubConfFromBase | [[SubConfFromBase_USR]]
}

protocol P2 { // CHECK: [[@LINE]]:10 | protocol/Swift | P2 | [[P2_USR:.*]] | Def |
  func foo() // CHECK: [[@LINE]]:8 | instance-method/Swift | foo() | [[P2_foo_USR:.*]] | Def
}
extension P2 { // CHECK: [[@LINE]]:11 | extension/ext-protocol/Swift | P2 | [[P2_ext_USR:.*]] | Def
  func foo() {} // CHECK: [[@LINE]]:8 | instance-method/Swift | foo() | [[P2_ext_foo_USR:.*]] | Def,Dyn,RelChild,RelOver | rel: 2
    // CHECK-NEXT: RelOver | instance-method/Swift | foo() | [[P2_foo_USR]]
    // CHECK-NEXT: RelChild | extension/ext-protocol/Swift | P2 | [[P2_ext_USR]]
}

struct ConfFromDefaultImpl: P2 { // CHECK: [[@LINE]]:8 | struct/Swift | ConfFromDefaultImpl | [[ConfFromDefaultImpl_USR:.*]] | Def
  // CHECK: [[@LINE-1]]:8 | instance-method/Swift | foo() | [[P2_ext_foo_USR]] | Impl,RelOver,RelCont | rel: 2
  // CHECK-NEXT: RelOver | instance-method/Swift | foo() | [[P2_foo_USR]]
  // CHECK-NEXT: RelCont | struct/Swift | ConfFromDefaultImpl | [[ConfFromDefaultImpl_USR]]
}

protocol P3 {
  func meth1() // CHECK: [[@LINE]]:8 | instance-method/Swift | meth1() | [[P3_meth1_USR:.*]] | Def
  func meth2() // CHECK: [[@LINE]]:8 | instance-method/Swift | meth2() | [[P3_meth2_USR:.*]] | Def
}

class BaseMultiConf {
  func meth2() {} // CHECK: [[@LINE]]:8 | instance-method/Swift | meth2() | [[BaseMultiConf_meth2_USR:.*]] | Def
}
extension SubMultiConf {
  func meth1() {} // CHECK: [[@LINE]]:8 | instance-method/Swift | meth1() | [[SubMultiConf_ext_meth1_USR:.*]] | Def
}
class SubMultiConf: BaseMultiConf,P2,P1,P3 { // CHECK: [[@LINE]]:7 | class/Swift | SubMultiConf | [[SubMultiConf_USR:.*]] | Def
  // CHECK: [[@LINE-1]]:7 | instance-method/Swift | foo() | [[P2_ext_foo_USR]] | Impl,RelOver,RelCont | rel: 2
    // CHECK-NEXT RelOver | instance-method/Swift | foo() | [[P2_foo_USR]]
    // CHECK-NEXT RelCont | class/Swift | SubMultiConf | [[SubMultiConf_USR]]
  // CHECK: [[@LINE-4]]:7 | instance-method/Swift | foo() | [[P2_ext_foo_USR]] | Impl,RelOver,RelCont | rel: 2
    // CHECK-NEXT RelOver | instance-method/Swift | foo() | [[P1_foo_USR]]
    // CHECK-NEXT RelCont | class/Swift | SubMultiConf | [[SubMultiConf_USR]]
  // CHECK: [[@LINE-7]]:7 | instance-method/Swift | meth1() | [[SubMultiConf_ext_meth1_USR]] | Impl,RelOver,RelCont | rel: 2
    // CHECK-NEXT RelOver | instance-method/Swift | meth1() | [[P3_meth1_USR]]
    // CHECK-NEXT RelCont | class/Swift | SubMultiConf | [[SubMultiConf_USR]]
  // CHECK: [[@LINE-10]]:7 | instance-method/Swift | meth2() | [[BaseMultiConf_meth2_USR]] | Impl,RelOver,RelCont | rel: 2
    // CHECK-NEXT RelOver | instance-method/Swift | meth2() | [[P3_meth2_USR]]
    // CHECK-NEXT RelCont | class/Swift | SubMultiConf | [[SubMultiConf_USR]]
  // CHECK-NOT: [[@LINE-13]]:7 | instance-method
}

protocol InheritingP: P1 { // CHECK: [[@LINE]]:10 | protocol/Swift | InheritingP | [[InheritingP_USR:.*]] | Def
  func foo() // CHECK: [[@LINE]]:8 | instance-method/Swift | foo() | [[InheritingP_foo_USR:.*]] | Def,Dyn,RelChild,RelOver | rel: 2
    // CHECK-NEXT: RelOver | instance-method/Swift | foo() | s:14swift_ide_test2P1P3fooyyF
    // CHECK-NEXT: RelChild | protocol/Swift | InheritingP | [[InheritingP_USR]]
}

struct DirectConf2: InheritingP { // CHECK: [[@LINE]]:8 | struct/Swift | DirectConf2 | [[DirectConf2_USR:.*]] | Def
  // FIXME: Should only override InheritingP.foo()
  func foo() {} // CHECK: [[@LINE]]:8 | instance-method/Swift | foo() | [[DirectConf2_foo_USR:.*]] | Def,RelChild,RelOver | rel: 3
    // CHECK-NEXT: RelOver | instance-method/Swift | foo() | [[InheritingP_foo_USR]]
    // CHECK-NEXT: RelOver | instance-method/Swift | foo() | [[P1_foo_USR]]
    // CHECK-NEXT: RelChild | struct/Swift | DirectConf2 | [[DirectConf2_USR]]
}

extension InheritingP { // CHECK: [[@LINE]]:11 | extension/ext-protocol/Swift | InheritingP | [[InheritingP_USR:.*]] | Def
  func foo() {} // CHECK: [[@LINE]]:8 | instance-method/Swift | foo() | [[InheritingP_ext_foo_USR:.*]] | Def,Dyn,RelChild,RelOver | rel: 2
    // CHECK-NEXT: RelOver | instance-method/Swift | foo() | [[InheritingP_foo_USR]]
    // CHECK-NEXT: RelChild | extension/ext-protocol/Swift | InheritingP | [[InheritingP_USR]]
}

protocol WithAssocType {
  associatedtype T // CHECK: [[@LINE]]:18 | type-alias/associated-type/Swift | T | [[WithAssocT_USR:.*]] | Def
  func foo() -> T // CHECK: [[@LINE]]:17 | type-alias/associated-type/Swift | T | [[WithAssocT_USR]] | Ref
}

struct SAssocTypeAlias: WithAssocType {
  typealias T = Int // CHECK: [[@LINE]]:13 | type-alias/Swift | T | [[SAssocT:.*]] | Def,RelChild,RelOver | rel: 2
    // CHECK-NEXT: RelOver | type-alias/associated-type/Swift | T | [[WithAssocT_USR]]
    // CHECK-NEXT: RelChild | struct/Swift | SAssocTypeAlias
  func foo() -> T { return 0 } // CHECK: [[@LINE]]:17 | type-alias/Swift | T | [[SAssocT:.*]] | Ref
}

struct SAssocTypeInferred: WithAssocType {
  func foo() -> Int { return 1 }
  func bar() -> T { return 2 } // CHECK: [[@LINE]]:17 |  type-alias/associated-type/Swift | T | [[WithAssocT_USR]] | Ref
}

struct AssocViaExtension {
  struct T {} // CHECK: [[@LINE]]:10 | struct/Swift | T | [[AssocViaExtensionT_USR:.*]] | Def
  func foo() -> T { return T() }
}

extension AssocViaExtension: WithAssocType {} // CHECK: [[@LINE]]:11 | struct/Swift | T | [[AssocViaExtensionT_USR]] | Impl,RelOver,RelCont | rel: 2
  // CHECK-NEXT: RelOver | type-alias/associated-type/Swift | T | [[WithAssocT_USR]]
  // CHECK-NEXT: RelCont | extension/ext-struct/Swift | AssocViaExtension
