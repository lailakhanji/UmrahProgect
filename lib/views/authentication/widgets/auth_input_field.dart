import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AuthInputField extends StatefulWidget {
 final String hintText;
 final IconData prefixIcon;
 final IconData? sufixIcon;
final bool obscure;
final TextEditingController  controller;
final String? Function (String?)? validator;
 const AuthInputField({super.key, required this.hintText, required this.prefixIcon, this.sufixIcon,  this.obscure=false, required this.controller, this.validator});

  @override
  State<AuthInputField> createState() => _AuthInputFieldState();
}

class _AuthInputFieldState extends State<AuthInputField> {
  late bool obscure;
  @override
  void initState() {
   obscure=widget.obscure;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: TextFormField(

controller: widget.controller,
      obscureText:obscure,
        obscuringCharacter: '*',
        validator: (value){
          if(value==null||value.isEmpty) {
            return '${widget.hintText} لا يجب أن يكون فارغاً  ';
          }
          if(widget.validator!=null)
            {
              String? error=widget.validator!(value);
              return error;
            }
          return null;
        },
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 14,vertical: 12),
          prefixIcon: Icon(widget.prefixIcon,
            size: 24,
            color: Theme.of(context).colorScheme.secondary,

          ),
          suffixIcon:widget.sufixIcon==null?null: InkWell(
            onTap: (){
      setState(() {
        obscure=!obscure;
      });
            },
            child:Icon( obscure?Icons.visibility_off_outlined:widget.sufixIcon,

              size: 24,
              color: Theme.of(context).colorScheme.secondary,

            ),
          ),
          hintText:widget.hintText,
          hintStyle:Theme.of(context).textTheme.titleSmall,
          filled: true,
          fillColor: Theme.of(context).colorScheme.inverseSurface,
          enabledBorder: OutlineInputBorder(borderRadius:BorderRadius.circular(12),
         borderSide:BorderSide(color:Theme.of(context).colorScheme.inverseSurface),

          ),
          errorBorder: OutlineInputBorder(borderRadius:BorderRadius.circular(8),
            borderSide:BorderSide(color:Colors.red),

          ),
          errorStyle: TextStyle(color: Colors.red,fontSize: 10),
          focusedErrorBorder: OutlineInputBorder(borderRadius:BorderRadius.circular(8),
        borderSide:BorderSide(color:Colors.red,),

      ),

          focusedBorder: OutlineInputBorder(borderRadius:BorderRadius.circular(12),
            borderSide:BorderSide(color:Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),width: 1.5),

          ),
        ),
      ),
    );
  }
}
