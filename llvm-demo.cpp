#include <llvm/ADT/ArrayRef.h>
#include <llvm/IR/LLVMContext.h>
#include <llvm/IR/Module.h>
#include <llvm/IR/Function.h>
#include <llvm/IR/BasicBlock.h>
#include <llvm/IR/IRBuilder.h>
#include <vector>
#include <string>

using namespace llvm;
using namespace std;
int main()
{
	LLVMContext &context = getGlobalContext();
	Module module("demo", context);
	IRBuilder<> builder(context);
	FunctionType *main = FunctionType::get(builder.getInt32Ty(), false);
	Function *mainFn =
	    Function::Create(main, Function::ExternalLinkage, "main", &module);
	BasicBlock *mainBlk = BasicBlock::Create(context, "entry", mainFn);
	builder.SetInsertPoint(mainBlk);

	Value *str = builder.CreateGlobalStringPtr("Hello World!", "str");

	vector<Type *> args;
	// args.push_back(builder.getInt8Ty()->getPointerTo());
	args.push_back(builder.getInt8PtrTy());
	FunctionType *puts =
	    FunctionType::get(builder.getInt32Ty(), args, false);
	// Function *putsFn = Function::Create(puts, Function::ExternalLinkage,
	// "puts", &module);
	Constant *putsFn = module.getOrInsertFunction("puts", puts);

	builder.CreateCall(putsFn, str);

	builder.CreateRet(builder.getInt32(0));
	module.dump();

	return 0;
}
