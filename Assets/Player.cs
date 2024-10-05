using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Player : MonoBehaviour
{
    public float _MoveSpeed = 5.0f;
    private float _rotSpeed = 50.0f;
    private Vector3 _movement;
    private Rigidbody _rigidbody;
    public GameObject _Camera;
    public radial_Camera _intensity;
    public float _Horizontal;
    public float _Vertical;
    private float rotationX = 0.0f;
    private float rotationY = 0.0f;
    private bool showMouse = true;
    // Start is called before the first frame update
    void Start()
    {
        _rigidbody = GetComponent<Rigidbody>();
        _intensity=_Camera.GetComponent<radial_Camera>();
        Cursor.visible = true;
        Cursor.lockState = CursorLockMode.Locked;
    }

    void FixedUpdate()
    {
        _Horizontal = Input.GetAxis("Horizontal");
        _Vertical = Input.GetAxis("Vertical");

        Run(_Horizontal, _Vertical);






        float MouseX = Input.GetAxis("Mouse X");
        float MouseY = Input.GetAxis("Mouse Y");


        rotationX += MouseX * _rotSpeed * Time.deltaTime;
        rotationY += MouseY * _rotSpeed * Time.deltaTime;
        if (rotationY < -55)
            rotationY = -55;
        else if (rotationY > 35)
            rotationY = 35;
        transform.eulerAngles = new Vector3(-rotationY, rotationX, 0.0f);
    }
    // Update is called once per frame
    void Update()
    {
        if (Input.GetKey(KeyCode.LeftShift))
        {
            _MoveSpeed = 10;
            _intensity.intensity = 1;
        }
        if (Input.GetKeyUp(KeyCode.LeftShift))
        {
            _MoveSpeed = 5;
            _intensity.intensity = 0;
        }

    }
    void Run(float h,float v)
    {
        _movement = (Vector3.forward * v) + (Vector3.right * h);
        gameObject.transform.Translate(_movement.normalized * _MoveSpeed * Time.deltaTime, Space.Self);
    }
}
